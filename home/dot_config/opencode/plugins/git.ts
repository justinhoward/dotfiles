import { Plugin } from "@opencode/plugin"

/**
 * Git operations that cannot run in the Fence-sandboxed bash tool.
 *
 * This plugin registers two tools, `git_commit` and `git_push`. Both run in
 * opencode's own process, outside Fence, so their behaviour is fixed here
 * rather than left to arbitrary arguments, and OpenCode's `permissions` config
 * (see opencode.jsonc) is their only gate: each tool calls
 * `ctx.permission.assert` with the resource patterns the config rules match.
 *
 * Git hooks (pre-commit, commit-msg, pre-push, ...) run normally, which means
 * they also run outside Fence. That matches running git in your own terminal,
 * which would execute the same hooks.
 *
 * Each tool runs git in the invoking session's working directory, resolved
 * from `ctx.session.get(...).location.directory`.
 */

const REMOTE = "origin"
const ALWAYS_PROTECTED = ["main", "master"]
const MAX_COMMITS_SHOWN = 50

type Result = { ok: boolean; stdout: string; stderr: string }

const gitIn = (directory: string) => async (...args: string[]): Promise<Result> => {
  const r = await Bun.$`git ${args}`
    .cwd(directory)
    // Never block on a credential prompt or open an editor: there is no
    // terminal for the agent to answer either.
    .env({ ...process.env, GIT_TERMINAL_PROMPT: "0", GIT_EDITOR: "true" })
    .quiet()
    .nothrow()
  return {
    ok: r.exitCode === 0,
    stdout: r.stdout.toString().trim(),
    stderr: r.stderr.toString().trim(),
  }
}

const currentBranch = async (git: ReturnType<typeof gitIn>) => {
  const head = await git("symbolic-ref", "--quiet", "--short", "HEAD")
  // --quiet makes a detached HEAD fail silently; any stderr is a real error
  // such as "not a git repository".
  if (!head.ok)
    throw new Error(head.stderr || "HEAD is detached; check out a branch first.")
  return head.stdout
}

export default Plugin.define({
  id: "git",
  async setup(ctx) {
    const sessionDirectory = async (sessionID: string) =>
      (await ctx.session.get({ sessionID })).location.directory

    await ctx.tool.transform((editor) => {
      /**
       * Commit what is staged, signed per the user's git config.
       *
       * Exists because commit.gpgSign is on and Fence denies reading ~/.gnupg,
       * so `git commit` fails inside the bash tool. Guarantees:
       *   - Commits only what is already staged (stage with `git add` in bash).
       *   - Never passes --no-verify; hooks run.
       *   - Amend may rewrite a commit already pushed to this branch's own
       *     remote branch (git_push with force: true then updates it), but not
       *     one on any other remote branch, e.g. a commit already on origin/main.
       */
      editor.add({
        name: "git_commit",
        description:
          "Create a git commit from the currently staged changes. Use this instead " +
          "of `git commit` in bash, which is blocked (commits are GPG-signed and the " +
          "sandbox cannot reach the signing key). Stage files with `git add` in bash " +
          "first. Can amend the last commit; if it was already pushed, push again " +
          "with git_push force: true.",
        input: {
          type: "object",
          properties: {
            message: {
              type: "string",
              description:
                "Full commit message: subject line, then a blank line and body if needed. " +
                "Required unless amend is true, where omitting it keeps the existing message.",
            },
            amend: {
              type: "boolean",
              description:
                "Amend the last commit instead of creating a new one. Refused if the " +
                "commit is on a remote branch other than this branch's own.",
            },
          },
          additionalProperties: false,
        },
        execute: async (input, context) => {
          const args = (input ?? {}) as { message?: string; amend?: boolean }
          const git = gitIn(await sessionDirectory(context.sessionID))
          const message = args.message?.trim()
          const amend = args.amend ?? false

          if (!amend && !message) throw new Error("A commit message is required.")

          // Exit 1 means there are staged changes; anything else non-zero is an
          // error. On an unborn branch this compares against the empty tree.
          const staged = await git("diff", "--cached", "--quiet")
          if (!staged.ok && staged.stderr) throw new Error(staged.stderr)
          const hasStaged = !staged.ok
          if (!hasStaged && !amend)
            throw new Error("Nothing is staged. Stage changes with `git add` in bash first.")

          let pushed = false
          if (amend) {
            if (!hasStaged && !message)
              throw new Error("Nothing to amend: no staged changes and no new message.")

            // Remote-tracking refs containing HEAD, minus symrefs like origin/HEAD.
            const refs = await git("for-each-ref", "--contains", "HEAD", "--format=%(refname)\t%(symref)", "refs/remotes")
            if (!refs.ok) throw new Error(refs.stderr || "Cannot inspect HEAD for amend.")
            const containing = refs.stdout
              .split("\n")
              .map((line) => line.split("\t"))
              .filter(([name, symref]) => name && !symref)
              .map(([name]) => name)

            const branch = (await git("symbolic-ref", "--quiet", "--short", "HEAD")).stdout
            const own = branch ? `refs/remotes/${REMOTE}/${branch}` : undefined
            const shared = containing.filter((name) => name !== own)
            if (shared.length)
              throw new Error(
                `HEAD is already on ${shared.map((n) => n.replace("refs/remotes/", "")).join(", ")}; ` +
                  "amending would fork history shared beyond this branch. Make a new commit instead.",
              )
            pushed = containing.length > 0
          }

          const subject = message?.split("\n")[0]
          // For amends, name the commit being rewritten so the approval prompt
          // says what is changing, not just the new message.
          const target = amend ? (await git("log", "-1", "--format=%h %s")).stdout : undefined
          const stagedFiles = hasStaged ? (await git("diff", "--cached", "--name-only")).stdout : ""
          await context.progress({
            title: amend
              ? `git commit --amend ${target}` +
                (subject ? ` -> ${subject}` : " (message unchanged)") +
                (pushed ? " [already pushed: needs git_push force]" : "")
              : `git commit: ${subject}`,
            amend,
            target,
            stagedFiles,
            pushed,
          })
          await ctx.permission.assert({
            sessionID: context.sessionID,
            agent: context.agent,
            action: "git_commit",
            resources: [amend ? "amend" : "new"],
            save: [amend ? "amend" : "new"],
            metadata: { amend, target, message, stagedFiles, pushed },
            source: { type: "tool", messageID: context.messageID, id: context.id },
          })

          const flags = amend ? ["--amend"] : []
          // With -m git only trims whitespace, so lines starting with "#" survive.
          const msgArgs = message ? ["-m", message] : ["--no-edit"]
          const res = await git("commit", ...flags, ...msgArgs)
          const output = [res.stdout, res.stderr].filter(Boolean).join("\n")
          if (!res.ok) throw new Error(`git commit failed:\n${output}`)

          // %G? is G for a good signature, N for unsigned; anything else is worth
          // surfacing as-is.
          const info = await git("log", "-1", "--format=%h %s%nsignature: %G? %GS")
          return { content: `${info.stdout}\n\n${output}` }
        },
      })

      /**
       * Approval-gated `git push` for the current branch.
       *
       * Fence denies `git push` in the bash tool outright: it has no "ask"
       * verdict, and its prefix matching cannot express "force, but only
       * safely". This is the narrow alternative, asking for approval via the
       * `git_push` permission after showing exactly what will be pushed (and,
       * for a force push, what will be discarded from the remote).
       *
       * Guarantees:
       *   - Pushes only the currently checked-out branch, to the same name on origin.
       *   - Refuses the remote's default branch (from `ls-remote --symref`) and
       *     main/master regardless, forced or not.
       *   - Without force: fast-forward only.
       *   - With force (only used when actually non-fast-forward):
       *       1. The remote tip must equal the local remote-tracking ref, i.e.
       *          nothing was pushed since the last fetch.
       *       2. --force-with-lease rejects the push if the remote moves after
       *          that check.
       *       3. --force-if-includes rejects it unless the remote tip is in this
       *          branch's reflog, i.e. it was integrated locally (as before an
       *          amend or rebase), not merely fetched.
       *   - Refuses if HEAD moved while the approval prompt was open.
       *
       * Approval patterns are the branch name for normal pushes and
       * "force:<branch>" for force pushes, so "always" for one does not cover
       * the other.
       */
      editor.add({
        name: "git_push",
        description:
          "Push the current git branch to origin and set it as upstream. Refuses " +
          "the repository's default branch and main/master. Use this instead of " +
          "`git push` in bash, which is blocked. The user is asked to approve each " +
          "push. Set force: true to replace the remote branch after an amend or " +
          "rebase; it is refused if the remote has commits you have not fetched " +
          "and integrated.",
        input: {
          type: "object",
          properties: {
            force: {
              type: "boolean",
              description:
                "Allow a non-fast-forward push (after amend/rebase), via " +
                "--force-with-lease and --force-if-includes. Ignored when the push " +
                "is a fast-forward anyway.",
            },
          },
          additionalProperties: false,
        },
        execute: async (input, context) => {
          const args = (input ?? {}) as { force?: boolean }
          const git = gitIn(await sessionDirectory(context.sessionID))
          const branch = await currentBranch(git)
          const ref = `refs/heads/${branch}`
          const trackingRef = `refs/remotes/${REMOTE}/${branch}`

          const localSha = (await git("rev-parse", "--verify", ref)).stdout

          // One round-trip for both the remote default branch and this branch's tip.
          // Output lines: "ref: refs/heads/main\tHEAD", "<sha>\tHEAD", "<sha>\t<ref>".
          const remote = await git("ls-remote", "--symref", REMOTE, "HEAD", ref)
          if (!remote.ok)
            throw new Error(`git ls-remote ${REMOTE} failed:\n${remote.stderr}`)
          let defaultBranch: string | undefined
          let remoteSha: string | undefined
          for (const line of remote.stdout.split("\n")) {
            const [left, right] = line.split("\t")
            if (right === "HEAD" && left.startsWith("ref: refs/heads/"))
              defaultBranch = left.slice("ref: refs/heads/".length)
            else if (right === ref) remoteSha = left
          }

          const protectedBranches = new Set(ALWAYS_PROTECTED)
          if (defaultBranch) protectedBranches.add(defaultBranch)
          if (protectedBranches.has(branch))
            throw new Error(
              `Refusing to push protected branch "${branch}". Create a feature branch instead.`,
            )

          if (remoteSha === localSha)
            return { content: `${REMOTE}/${branch} is already up to date at ${localSha.slice(0, 12)}.` }

          // Also not a fast-forward (exit 128) if the remote commit was never
          // fetched: we can't prove otherwise.
          const fastForward =
            !remoteSha || (await git("merge-base", "--is-ancestor", remoteSha, localSha)).ok

          let discarded = ""
          if (!fastForward) {
            if (!args.force)
              throw new Error(
                `${REMOTE}/${branch} (${remoteSha!.slice(0, 12)}) is not an ancestor of HEAD. ` +
                  "If you amended or rebased, retry with force: true. Otherwise fetch " +
                  "and integrate the remote changes first.",
              )
            const tracking = await git("rev-parse", "--verify", "--quiet", trackingRef)
            if (tracking.stdout !== remoteSha)
              throw new Error(
                `${REMOTE}/${branch} is at ${remoteSha!.slice(0, 12)} on the remote but ` +
                  `${tracking.stdout ? tracking.stdout.slice(0, 12) : "missing"} locally; ` +
                  "it changed since your last fetch. Fetch and review before force-pushing.",
              )
            discarded = (
              await git("log", "--oneline", "--no-decorate", `-n${MAX_COMMITS_SHOWN}`, `${localSha}..${remoteSha}`)
            ).stdout

            // Same test as --force-if-includes, run before prompting so a doomed
            // push fails without asking: the remote tip must be reachable from some
            // reflog entry of this branch. `rev-list --count X --not S` is 0 iff X
            // is reachable from S. Capped to keep argv small; a cap miss refuses,
            // which is the safe direction.
            const reflog = await git("log", "-g", "-n1000", "--format=%H", ref)
            const entries = [...new Set(reflog.stdout.split("\n").filter(Boolean))]
            const unintegrated = entries.length
              ? await git("rev-list", "--count", remoteSha!, "--not", ...entries)
              : undefined
            if (!unintegrated?.ok || unintegrated.stdout !== "0") {
              const foreign = entries.length
                ? (await git("log", "--oneline", "--no-decorate", `-n${MAX_COMMITS_SHOWN}`, remoteSha!, "--not", ...entries)).stdout
                : discarded
              throw new Error(
                `${REMOTE}/${branch} has commits that were fetched but never integrated into ` +
                  `${branch}; force-pushing would drop them:\n${foreign}\n` +
                  "Integrate or review them before force-pushing.",
              )
            }
          }
          const forcing = !fastForward

          // For a new branch, show commits since the local copy of the default branch.
          const base = remoteSha ?? (defaultBranch && `${REMOTE}/${defaultBranch}`)
          let log = base
            ? await git("log", "--oneline", "--no-decorate", `-n${MAX_COMMITS_SHOWN}`, `${base}..${localSha}`)
            : undefined
          if (!log?.ok) log = await git("log", "--oneline", "--no-decorate", "-n10", localSha)
          const commits = log.stdout

          const summary =
            `git push${forcing ? " --force-with-lease" : ""} ${REMOTE} ${branch}` +
            (remoteSha ? ` (${remoteSha.slice(0, 12)}..${localSha.slice(0, 12)})` : " (new branch)")
          const pattern = forcing ? `force:${branch}` : branch

          await context.progress({ title: summary, branch, remote: REMOTE, commits, discarded })
          await ctx.permission.assert({
            sessionID: context.sessionID,
            agent: context.agent,
            action: "git_push",
            resources: [pattern],
            save: [pattern],
            metadata: { branch, remote: REMOTE, force: forcing, newBranch: !remoteSha, localSha, remoteSha, commits, discarded },
            source: { type: "tool", messageID: context.messageID, id: context.id },
          })

          const after = (await git("rev-parse", "--verify", ref)).stdout
          if (after !== localSha)
            throw new Error(
              `${branch} moved from ${localSha.slice(0, 12)} to ${after.slice(0, 12)} during approval; not pushing.`,
            )

          // Full refs on both sides: a refspec can never pick up a leading "+".
          // The lease names the remote ref without an expected value, so git uses
          // the tracking ref checked above and --force-if-includes stays active.
          const forceFlags = forcing ? [`--force-with-lease=${ref}`, "--force-if-includes"] : []
          const res = await git("push", "--set-upstream", ...forceFlags, REMOTE, `${ref}:${ref}`)
          const output = [res.stdout, res.stderr].filter(Boolean).join("\n")
          if (!res.ok) throw new Error(`git push failed:\n${output}`)

          return {
            content:
              `${summary}\n\nCommits:\n${commits}` +
              (discarded ? `\n\nReplaced on ${REMOTE}:\n${discarded}` : "") +
              `\n\n${output}`,
          }
        },
      })
    })
  },
})
