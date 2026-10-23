import { Plugin } from "@opencode/plugin"
import { spawn } from "node:child_process"
import { createHash } from "node:crypto"
import { readFile, stat } from "node:fs/promises"
import { join } from "node:path"

/**
 * Git operations that cannot run in the Fence-sandboxed bash tool.
 *
 * This plugin registers commit, push, rebase, and merge tools. They run in
 * opencode's own process, outside Fence, so their behaviour is fixed here
 * rather than left to arbitrary arguments, and OpenCode's `permissions` config
 * (see opencode.jsonc) is their only gate: each tool calls
 * `ctx.permission.assert` with the resource patterns the config rules match.
 *
 * Git hooks (pre-commit, pre-rebase, commit-msg, pre-push, ...) run normally,
 * which means they also run outside Fence. That matches running git in your
 * own terminal, which would execute the same hooks.
 *
 * Each tool runs git in the invoking session's working directory, resolved
 * from `ctx.session.get(...).location.directory`.
 */

const REMOTE = "origin"
const ALWAYS_PROTECTED = ["main", "master"]
const MAX_COMMITS_SHOWN = 50

type Result = { ok: boolean; stdout: string; stderr: string }

const gitIn = (directory: string, signal?: AbortSignal) => (...args: string[]): Promise<Result> =>
  new Promise((resolve, reject) => {
    // An argv array, never a shell string. Respect session cancellation and
    // leave interrupted Git operations in place for explicit recovery.
    const child = spawn("git", args, {
      cwd: directory, signal,
      // Never open an editor or block on a Git credential prompt.
      env: { ...process.env, GIT_TERMINAL_PROMPT: "0", GIT_EDITOR: "true", GIT_SEQUENCE_EDITOR: "true" },
      stdio: ["ignore", "pipe", "pipe"],
    })
    let stdout = ""
    let stderr = ""
    child.stdout.setEncoding("utf8").on("data", (data: string) => { stdout += data })
    child.stderr.setEncoding("utf8").on("data", (data: string) => { stderr += data })
    child.on("error", reject)
    child.on("close", (code, killedBy) => {
      if (killedBy) reject(new Error(`git was interrupted (${killedBy}); inspect its state before continuing.`))
      else resolve({ ok: code === 0, stdout: stdout.replace(/\n$/, ""), stderr: stderr.trim() })
    })
  })

const currentBranch = async (git: ReturnType<typeof gitIn>) => {
  const head = await git("symbolic-ref", "--quiet", "--short", "HEAD")
  // --quiet makes a detached HEAD fail silently; any stderr is a real error
  // such as "not a git repository".
  if (!head.ok)
    throw new Error(head.stderr || "HEAD is detached; check out a branch first.")
  return head.stdout
}

type Git = ReturnType<typeof gitIn>
type Operation = "rebase" | "merge"
type Action = "start" | "continue" | "abort" | "skip"
type RebaseInput = {
  action?: Action
  upstream?: string
  branch?: string
  onto?: string
  root?: boolean
  keepBase?: boolean
  rebaseMerges?: boolean | "no-rebase-cousins" | "rebase-cousins"
  autosquash?: boolean
  forceRebase?: boolean
  reapplyCherryPicks?: boolean
  forkPoint?: boolean
  empty?: "drop" | "keep" | "stop"
  keepEmpty?: boolean
  signoff?: boolean
  committerDateIsAuthorDate?: boolean
  resetAuthorDate?: boolean
}
type MergeInput = {
  action?: Exclude<Action, "skip">
  ref?: string
  ff?: "ff" | "no-ff" | "ff-only"
  squash?: boolean
  noCommit?: boolean
  message?: string
  signoff?: boolean
  verifySignatures?: boolean
  allowUnrelatedHistories?: boolean
}

const checked = async (git: Git, ...args: string[]) => {
  const result = await git(...args)
  if (!result.ok) throw new Error(result.stderr || result.stdout || `git ${args[0]} failed.`)
  return result.stdout
}

const revision = (value: string) => {
  if (!value || value.startsWith("-") || /[\0\r\n]/.test(value))
    throw new Error(`Invalid revision: ${JSON.stringify(value)}.`)
  return value
}

const commit = async (git: Git, ref: string) =>
  checked(git, "rev-parse", "--verify", "--end-of-options", `${revision(ref)}^{commit}`)

// --onto accepts A...B (including an omitted endpoint) when there is exactly
// one merge base. Freeze that shorthand to a SHA before asking for approval.
const ontoCommit = async (git: Git, ref: string, head: string) => {
  revision(ref)
  if (!ref.includes("...")) return commit(git, ref)
  const parts = ref.split("...")
  if (parts.length !== 2) throw new Error("--onto expects one A...B expression.")
  const bases = await checked(git, "merge-base", "--all",
    await commit(git, parts[0] || head), await commit(git, parts[1] || head))
  if (bases.split("\n").length !== 1 || !bases)
    throw new Error("--onto A...B requires exactly one merge base.")
  return bases
}

const optionalFile = async (path: string): Promise<string | null> => {
  try {
    return await readFile(path, "utf8")
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") return null
    throw error
  }
}

const exists = async (path: string) => {
  try {
    await stat(path)
    return true
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") return false
    throw error
  }
}

// Resolve the per-worktree Git directory, not <cwd>/.git: linked worktrees
// have their own rebase/merge state in the common repo's worktrees directory.
const operationState = async (git: Git) => {
  const directory = await checked(git, "rev-parse", "--absolute-git-dir")
  const files = [
    "MERGE_HEAD", "MERGE_MSG", "MERGE_MODE", "MERGE_AUTOSTASH", "ORIG_HEAD",
    "CHERRY_PICK_HEAD", "REVERT_HEAD", "BISECT_LOG",
    ...["rebase-merge", "rebase-apply"].flatMap((dir) => [
      "head-name", "orig-head", "onto", "gpg_sign_opt", "git-rebase-todo",
      "done", "stopped-sha", "update-refs", "autostash", "applying",
      "strategy", "strategy_opts", "reschedule-failed-exec", "allow_rerere_autoupdate",
      "message", "message-squash", "message-fixup", "author-script", "amend",
      "rewritten-list", "squash-onto", "end", "msgnum",
    ].map((file) => `${dir}/${file}`)),
  ]
  const contents = Object.fromEntries(await Promise.all(files.map(async (file) =>
    [file, await optionalFile(join(directory, file))] as const)))
  const rebase = await exists(join(directory, "rebase-merge")) ? "rebase-merge"
    : await exists(join(directory, "rebase-apply")) ? "rebase-apply" : undefined
  const sequencer = await exists(join(directory, "sequencer"))
  return { contents, rebase, merge: contents.MERGE_HEAD !== null, sequencer }
}

type State = Awaited<ReturnType<typeof operationState>>

const idle = (state: State) => {
  if (state.rebase || state.merge || state.sequencer ||
      state.contents.CHERRY_PICK_HEAD !== null || state.contents.REVERT_HEAD !== null ||
      state.contents.BISECT_LOG !== null)
    throw new Error("Another Git operation is in progress. Finish or explicitly abort it first.")
}

const cleanStart = async (git: Git) => {
  const status = await checked(git, "status", "--porcelain=v1", "--untracked-files=no")
  if (status) throw new Error("Tracked files must be clean before starting. Commit or stash changes yourself first.")
}

const unmerged = async (git: Git) => {
  const names = await checked(git, "diff", "--name-only", "--diff-filter=U", "-z")
  return names.split("\0").filter(Boolean)
}

const allowedBranch = async (git: Git, branch: string) => {
  revision(branch)
  await checked(git, "check-ref-format", "--branch", branch)
  const remoteHead = await git("symbolic-ref", "--quiet", "--short", `refs/remotes/${REMOTE}/HEAD`)
  const configured = await git("config", "--get", "init.defaultBranch")
  const protectedBranches = new Set([
    ...ALWAYS_PROTECTED,
    ...(remoteHead.ok ? [remoteHead.stdout.replace(`${REMOTE}/`, "")] : []),
    ...(configured.ok ? [configured.stdout] : []),
  ])
  if (protectedBranches.has(branch))
    throw new Error(`Refusing to change protected branch "${branch}". Use a feature branch instead.`)
  await commit(git, `refs/heads/${branch}`)
}

// Include content, not just file names/status codes: a conflict resolution can
// change while its file stays marked M. Do not execute external diff drivers.
const snapshot = async (git: Git) => {
  const [head, branch, status, staged, working, state] = await Promise.all([
    commit(git, "HEAD"), git("symbolic-ref", "--quiet", "HEAD"),
    checked(git, "status", "--porcelain=v1", "--untracked-files=all"),
    checked(git, "diff", "--cached", "--binary", "--no-ext-diff", "--no-textconv"),
    checked(git, "diff", "--binary", "--no-ext-diff", "--no-textconv"),
    operationState(git),
  ])
  return createHash("sha256").update(JSON.stringify({ head, branch: branch.stdout, status, staged, working, state })).digest("hex")
}

const resumeBranch = async (git: Git, state: State, operation: Operation) => {
  if (operation === "merge") {
    if (state.rebase || !state.merge) throw new Error("No standalone merge is in progress.")
    return currentBranch(git)
  }
  if (!state.rebase || state.contents[`${state.rebase}/applying`] !== null)
    throw new Error("No rebase is in progress (git am is not a rebase).")
  const name = state.contents[`${state.rebase}/head-name`]?.trim()
  if (!name?.startsWith("refs/heads/")) throw new Error("Cannot safely identify the branch being rebased.")
  return name.slice("refs/heads/".length)
}

const safeRebaseResume = (state: State) => {
  // Git only accepts `rebase --continue` by itself. The signing choice is
  // persisted in this file by --gpg-sign at start and read on continuation.
  if (state.rebase !== "rebase-merge" || !state.contents["rebase-merge/gpg_sign_opt"]?.startsWith("-S"))
    throw new Error("Only signing-enabled merge-backend rebases can be continued. Abort and restart with git_rebase.")
  const todo = state.contents["rebase-merge/git-rebase-todo"] ?? ""
  if (/^\s*(?:exec|x|update-ref|u)\s/m.test(todo) || state.contents["rebase-merge/update-refs"]?.trim())
    throw new Error("Refusing a rebase todo with exec or update-ref instructions. This tool does not run commands or rewrite other branches.")
  const strategy = state.contents["rebase-merge/strategy"]?.trim()
  if (strategy && !["ort", "recursive"].includes(strategy))
    throw new Error("Refusing to continue a rebase with a custom merge strategy.")
  if (state.contents["rebase-merge/strategy_opts"]?.trim())
    throw new Error("Refusing to continue a rebase with custom merge strategy options.")
  if (state.contents["rebase-merge/autostash"] !== null)
    throw new Error("Refusing to continue a rebase with an automatic stash; finish it manually or explicitly abort.")
}

const actionInput = (args: { action?: string }, operation: Operation): Action => {
  const action = args.action ?? "start"
  if (!["start", "continue", "abort", ...(operation === "rebase" ? ["skip"] : [])].includes(action))
    throw new Error(`Invalid ${operation} action: ${action}.`)
  if (action !== "start" && Object.keys(args).some((key) => key !== "action"))
    throw new Error("Continuation, skip, and abort accept only action; start options are saved by Git.")
  return action as Action
}

const rebaseFlags = (args: RebaseInput) => {
  if (args.root && (args.upstream || args.keepBase || args.forkPoint))
    throw new Error("root cannot be combined with upstream, keepBase, or forkPoint: true.")
  if (args.keepBase && args.onto) throw new Error("keepBase and onto are mutually exclusive.")
  if (args.branch && !args.upstream && !args.root)
    throw new Error("branch requires upstream (both positional arguments), or root: true.")
  if (args.empty && !["drop", "keep", "stop"].includes(args.empty)) throw new Error("Invalid empty mode.")
  if (args.rebaseMerges !== undefined && ![true, false, "no-rebase-cousins", "rebase-cousins"].includes(args.rebaseMerges))
    throw new Error("Invalid rebaseMerges mode.")
  const flags = ["--merge", "--gpg-sign", "--verify", "--no-autostash", "--no-update-refs", "--no-rerere-autoupdate"]
  flags.push(typeof args.rebaseMerges === "string" ? `--rebase-merges=${args.rebaseMerges}`
    : args.rebaseMerges ? "--rebase-merges" : "--no-rebase-merges")
  flags.push(args.autosquash ? "--autosquash" : "--no-autosquash")
  if (args.autosquash) flags.push("--interactive") // automatic fixup/squash only; no editable todo
  for (const [key, flag] of [
    ["forceRebase", "--force-rebase"], ["signoff", "--signoff"],
    ["committerDateIsAuthorDate", "--committer-date-is-author-date"], ["resetAuthorDate", "--reset-author-date"],
  ] as const) if (args[key]) flags.push(flag)
  if (args.reapplyCherryPicks !== undefined) flags.push(args.reapplyCherryPicks ? "--reapply-cherry-picks" : "--no-reapply-cherry-picks")
  if (args.keepEmpty !== undefined) flags.push(args.keepEmpty ? "--keep-empty" : "--no-keep-empty")
  if (args.empty) flags.push(`--empty=${args.empty}`)
  return flags
}

const mergeFlags = (args: MergeInput) => {
  if (args.ff && !["ff", "no-ff", "ff-only"].includes(args.ff)) throw new Error("Invalid ff mode.")
  if (args.squash && args.ff === "no-ff") throw new Error("squash and ff: no-ff are incompatible.")
  if (args.message !== undefined && !args.message.trim()) throw new Error("message must not be empty.")
  const flags = ["--gpg-sign", "--no-edit", "--verify", "--no-autostash", "--no-rerere-autoupdate", "--no-overwrite-ignore", `--${args.ff ?? "ff"}`]
  flags.push(args.squash ? "--squash" : "--no-squash", args.squash || args.noCommit ? "--no-commit" : "--commit")
  if (args.message) flags.push("-m", args.message)
  if (args.signoff) flags.push("--signoff")
  if (args.verifySignatures) flags.push("--verify-signatures")
  if (args.allowUnrelatedHistories) flags.push("--allow-unrelated-histories")
  return flags
}

const rebasePlan = async (git: Git, args: RebaseInput, branch: string) => {
  const flags = rebaseFlags(args)
  const head = await commit(git, `refs/heads/${branch}`)
  const implicit = !args.upstream && !args.root
  const upstream = args.root ? undefined : args.upstream ?? await checked(git, "rev-parse", "--symbolic-full-name", `${branch}@{upstream}`)
  const upstreamSha = upstream ? await commit(git, upstream) : undefined
  const forkPoint = args.forkPoint ?? (implicit && !args.keepBase && !args.root)
  let fork: string | undefined
  if (forkPoint && upstream) {
    const result = await git("merge-base", "--fork-point", upstream, head)
    if (!result.ok && result.stderr) throw new Error(result.stderr)
    if (result.ok) fork = result.stdout
  }
  const onto = args.keepBase ? await ontoCommit(git, `${upstreamSha}...${head}`, head)
    : args.onto ? await ontoCommit(git, args.onto, await commit(git, "HEAD")) : upstreamSha
  if (args.keepBase) flags.push("--keep-base")
  else if (onto) flags.push("--onto", onto)
  flags.push(forkPoint ? "--fork-point" : "--no-fork-point")
  if (args.root) flags.push("--root")
  // Keep the named upstream for --fork-point, which consults its reflog.
  // Its resolved SHA (and computed fork point) are rechecked after approval.
  const argv = [...flags, "--", ...(upstream ? [forkPoint ? upstream : upstreamSha!] : []), branch]
  const excluded = upstreamSha ?? (args.root ? onto : undefined)
  const range = [head, ...(excluded ? ["--not", excluded, ...(fork ? [fork] : [])] : [])]
  const commits = await checked(git, "log", "--oneline", "--no-decorate", `-n${MAX_COMMITS_SHOWN}`, ...range)

  // Protect every replay candidate, not just HEAD: --onto can rewrite a range
  // whose older commits are already shared on another remote branch.
  const candidates = (await checked(git, "rev-list", ...range)).split("\n").filter(Boolean)
  const refs = await checked(git, "for-each-ref", "--format=%(refname)\t%(symref)", "refs/remotes")
  const otherRefs = refs.split("\n").map((line) => line.split("\t"))
    .filter(([ref, symref]) => ref && !symref && ref !== `refs/remotes/${REMOTE}/${branch}`)
    .map(([ref]) => ref)
  for (let i = 0; i < candidates.length; i += 100) {
    const batch = candidates.slice(i, i + 100)
    // Batch both sides to bound argv size and avoid one Git process per remote
    // branch in repositories with thousands of remote-tracking refs.
    for (let j = 0; j < otherRefs.length; j += 100) {
      const remoteBatch = otherRefs.slice(j, j + 100)
      const unshared = await checked(git, "rev-list", "--count", "--no-walk", ...batch, "--not", ...remoteBatch)
      if (Number(unshared) === batch.length) continue
      for (const candidate of batch) {
        const containing = await checked(git, "for-each-ref", "--contains", candidate, "--format=%(refname)", "refs/remotes")
        const shared = containing.split("\n").find((ref) => remoteBatch.includes(ref))
        if (shared)
          throw new Error(`The replay range includes commits already on ${shared.replace("refs/remotes/", "")}; rebasing would rewrite shared history.`)
      }
      // Fail closed if refs changed between the count and diagnostic query.
      throw new Error("Cannot prove the replay range is unshared; fetch, inspect remote refs, and retry.")
    }
  }
  return { argv, head, upstream, upstreamSha, onto, fork, branch, commits }
}

const operationResult = async (git: Git, operation: Operation, action: Action, result: Result, squash = false) => {
  const state = await operationState(git)
  const conflicts = await unmerged(git)
  const inProgress = operation === "rebase" ? !!state.rebase : state.merge
  const output = [result.stdout, result.stderr].filter(Boolean).join("\n")
  if (!result.ok && !inProgress && !conflicts.length) throw new Error(`git ${operation} failed:\n${output}`)
  const staged = squash ? await git("diff", "--cached", "--quiet") : undefined
  if (staged && !staged.ok && staged.stderr) throw new Error(staged.stderr)
  const status = conflicts.length ? "conflicts" : inProgress ? "in-progress" : staged && !staged.ok ? "staged" : "completed"
  const next = squash && (status === "staged" || conflicts.length)
    ? "Squash changes have no MERGE_HEAD. Resolve/stage any conflicts, then use git_commit to create the signed commit; git_merge continue/abort do not apply."
    : status === "conflicts" || status === "in-progress"
    ? `Resolve and stage files with git add in the sandbox, then call git_${operation} with action: continue. Abort is explicit and can discard resolution work.`
    : undefined
  const head = await checked(git, "log", "-1", "--format=%h %s%nsignature: %G? %GS")
  return { content: JSON.stringify({ operation, action, status, conflicts, head, next, output }, null, 2) }
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
       * Signed history operations. No arbitrary arguments, shell exec, custom
       * strategies, automatic stashes, or updates to other branches. Every
       * action is separately permission-gated, including destructive recovery.
       * A stopped rebase retains --gpg-sign in Git's own per-worktree state.
       */
      const actionSchema = {
        type: "string" as const,
        enum: ["start", "continue", "abort"],
        description: "Defaults to start. Continue/abort accept only action. Abort can discard conflict-resolution work.",
      }
      editor.add({
        name: "git_rebase",
        description:
          "Rebase with GPG signing for every recreated commit, outside the shell sandbox. " +
          "Supports git rebase [--onto newbase] [upstream [branch]], or --root [branch]. " +
          "Omitting upstream uses the current branch's tracking upstream. " +
          "Protected branches and replay ranges shared on other remote branches are refused (using local refs; fetch first). " +
          "Resolve conflicts and git add in the sandbox, then call action: continue. " +
          "Never use git_commit to finish a rebase. Skip/abort are explicit destructive actions. " +
          "No arbitrary interactive todo, exec, update-refs, strategy, or autostash options.",
        input: {
          type: "object",
          properties: {
            action: { ...actionSchema, enum: ["start", "continue", "abort", "skip"],
              description: actionSchema.description + " Skip drops the current patch and resolution work; use only when intentional." },
            upstream: { type: "string", description: "First positional argument: upstream whose ancestors are excluded from the replay range." },
            branch: { type: "string", description: "Second positional argument: existing local branch to check out and rebase. Requires upstream, or root: true. Defaults to the current branch." },
            onto: { type: "string", description: "--onto <newbase>: replay onto this revision instead of upstream. Accepts A...B with a unique merge base." },
            root: { type: "boolean", description: "--root: replay from the root; branch is the sole positional argument. Cannot combine with upstream, keepBase, or forkPoint: true." },
            keepBase: { type: "boolean", description: "--keep-base: keep the upstream/branch merge base. Incompatible with onto and root." },
            rebaseMerges: { anyOf: [{ type: "boolean" }, { type: "string", enum: ["no-rebase-cousins", "rebase-cousins"] }],
              description: "--rebase-merges, optionally with a cousin mode. Defaults to false (linear replay)." },
            autosquash: { type: "boolean", description: "Automatically apply fixup!/squash! commits with --autosquash. The sequence editor is disabled; not general interactive rebase." },
            forceRebase: { type: "boolean", description: "--force-rebase / --no-ff: recreate commits even when unchanged (useful for re-signing)." },
            reapplyCherryPicks: { type: "boolean", description: "--[no-]reapply-cherry-picks: replay changes already present upstream." },
            forkPoint: { type: "boolean", description: "--[no-]fork-point: consult the upstream reflog. Defaults to true for an omitted upstream, false otherwise (and for keepBase/root)." },
            empty: { type: "string", enum: ["drop", "keep", "stop"], description: "--empty: how to handle commits that become empty." },
            keepEmpty: { type: "boolean", description: "--[no-]keep-empty: retain commits that were originally empty." },
            signoff: { type: "boolean", description: "--signoff: add a Signed-off-by trailer (separate from GPG signing)." },
            committerDateIsAuthorDate: { type: "boolean", description: "--committer-date-is-author-date." },
            resetAuthorDate: { type: "boolean", description: "--reset-author-date / --ignore-date: use the current author date." },
          },
          additionalProperties: false,
        },
        execute: async (input, context) => {
          const args = (input ?? {}) as RebaseInput
          const action = actionInput(args, "rebase")
          const git = gitIn(await sessionDirectory(context.sessionID), context.signal)
          const state = await operationState(git)
          let plan: Awaited<ReturnType<typeof rebasePlan>> | undefined
          let branch: string
          if (action === "start") {
            idle(state)
            await cleanStart(git)
            branch = args.branch ?? await currentBranch(git)
            await allowedBranch(git, branch)
            plan = await rebasePlan(git, args, branch)
          } else {
            branch = await resumeBranch(git, state, "rebase")
            if (action !== "abort") {
              await allowedBranch(git, branch)
              safeRebaseResume(state)
            }
            if (action === "continue" && (await unmerged(git)).length)
              throw new Error("Unresolved conflicts remain. Resolve and stage them with git add before continuing.")
          }
          const before = await snapshot(git)
          const resource = `${action}:${branch}`
          const recovery = !plan ? {
            originalHead: state.contents[`${state.rebase}/orig-head`]?.trim(),
            onto: state.contents[`${state.rebase}/onto`]?.trim(),
            currentPatch: (await git("log", "-1", "--format=%h %s", "REBASE_HEAD")).stdout,
            stagedFiles: await checked(git, "diff", "--cached", "--name-only"),
          } : undefined
          const warning = action === "abort" ? "Aborting can discard all conflict-resolution work since the rebase started."
            : action === "skip" ? "Skipping drops the current patch and any resolution work for it." : undefined
          await context.progress({ title: `git rebase ${action}: ${branch}`, ...plan, ...recovery, warning })
          await ctx.permission.assert({
            sessionID: context.sessionID, agent: context.agent, action: "git_rebase",
            resources: [resource], save: [resource], metadata: { action, ...plan, ...recovery, branch, warning },
            source: { type: "tool", messageID: context.messageID, id: context.id },
          })
          if (context.signal.aborted) throw new Error("Rebase cancelled before execution.")
          if (await snapshot(git) !== before)
            throw new Error("Git state changed during approval; not rebasing. Inspect and retry.")
          if (plan) {
            await allowedBranch(git, branch)
            if (JSON.stringify(await rebasePlan(git, args, branch)) !== JSON.stringify(plan))
              throw new Error("Rebase revisions changed during approval; inspect and retry.")
          } else if (action !== "abort") {
            await allowedBranch(git, branch)
            safeRebaseResume(await operationState(git))
          }
          // Override instruction formatting so subjects cannot introduce todo
          // commands; continuation uses the saved -S, not illegal extra flags.
          const result = await git("-c", "commit.gpgSign=true", "-c", "core.commentChar=#",
            "-c", "rebase.instructionFormat=%s", "-c", "rebase.rescheduleFailedExec=false",
            "rebase", ...(plan ? plan.argv : [`--${action}`]))
          return operationResult(git, "rebase", action, result)
        },
      })

      editor.add({
        name: "git_merge",
        description:
          "Merge a revision into the current feature branch outside the sandbox, signing any new merge commit. " +
          "Fast-forwards create no commit. Supports ff/no-ff/ff-only, squash, noCommit, and message. " +
          "Resolve conflicts and git add in the sandbox, then call action: continue. " +
          "Squash leaves staged changes without a merge in progress; finish those with git_commit. " +
          "Abort is explicit and may discard resolution work. No custom strategies or autostash.",
        input: {
          type: "object",
          properties: {
            action: actionSchema,
            ref: { type: "string", description: "Revision to merge. Required for start; continue/abort accept only action." },
            ff: { type: "string", enum: ["ff", "no-ff", "ff-only"], description: "--ff (default), --no-ff, or --ff-only." },
            squash: { type: "boolean", description: "--squash: stage a combined change without a merge commit or MERGE_HEAD. Finish with git_commit; no continue/abort state." },
            noCommit: { type: "boolean", description: "--no-commit: pause before creating a merge commit. Does not stop a fast-forward; combine with ff: no-ff if needed." },
            message: { type: "string", description: "-m: message for a new merge commit. Ignored by fast-forward and squash." },
            signoff: { type: "boolean", description: "--signoff: add a Signed-off-by trailer." },
            verifySignatures: { type: "boolean", description: "--verify-signatures: require a valid trusted signature on the incoming tip." },
            allowUnrelatedHistories: { type: "boolean", description: "--allow-unrelated-histories: explicitly merge histories without a common ancestor." },
          },
          additionalProperties: false,
        },
        execute: async (input, context) => {
          const args = (input ?? {}) as MergeInput
          const action = actionInput(args, "merge")
          const git = gitIn(await sessionDirectory(context.sessionID), context.signal)
          const state = await operationState(git)
          let target: string | undefined
          let flags: string[] = []
          let branch: string
          if (action === "start") {
            if (!args.ref) throw new Error("ref is required to start a merge.")
            flags = mergeFlags(args)
            idle(state)
            await cleanStart(git)
            branch = await currentBranch(git)
            await allowedBranch(git, branch)
            target = await commit(git, args.ref)
            if (!args.message && !args.squash) flags.push("-m", `Merge ${args.ref} into ${branch}`)
          } else {
            branch = await resumeBranch(git, state, "merge")
            if (action !== "abort") await allowedBranch(git, branch)
            if (action === "continue" && state.contents.MERGE_AUTOSTASH !== null)
              throw new Error("Refusing to continue a merge with an automatic stash; finish it manually or explicitly abort.")
            if (action === "continue" && (await unmerged(git)).length)
              throw new Error("Unresolved conflicts remain. Resolve and stage them with git add before continuing.")
          }
          const before = await snapshot(git)
          const resource = `${action}:${branch}`
          const warning = action === "abort" ? "Aborting can discard conflict-resolution work since the merge started." : undefined
          const commits = target ? await checked(git, "log", "--oneline", "--no-decorate", `-n${MAX_COMMITS_SHOWN}`, `${await commit(git, "HEAD")}..${target}`) : undefined
          const recovery = !target ? {
            originalHead: state.contents.ORIG_HEAD?.trim(), incomingHeads: state.contents.MERGE_HEAD?.trim(),
            stagedFiles: await checked(git, "diff", "--cached", "--name-only"),
          } : undefined
          await context.progress({ title: `git merge ${action}: ${args.ref ?? branch}`, branch, target, flags, commits, ...recovery, warning })
          await ctx.permission.assert({
            sessionID: context.sessionID, agent: context.agent, action: "git_merge",
            resources: [resource], save: [resource], metadata: { action, branch, ref: args.ref, target, flags, commits, ...recovery, warning },
            source: { type: "tool", messageID: context.messageID, id: context.id },
          })
          if (context.signal.aborted) throw new Error("Merge cancelled before execution.")
          if (await snapshot(git) !== before || (target && await commit(git, args.ref!) !== target))
            throw new Error("Git state or merge target changed during approval; inspect and retry.")
          if (await currentBranch(git) !== branch)
            throw new Error("The current branch changed before approval; inspect and retry.")
          if (action !== "abort") await allowedBranch(git, branch)
          // merge --continue invokes git commit internally; -c also reaches
          // that child process. Only a normal MERGE_HEAD can be continued.
          const result = await git("-c", "commit.gpgSign=true", "merge",
            ...(target ? [...flags, "--", target] : [`--${action}`]))
          return operationResult(git, "merge", action, result, !!args.squash)
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
