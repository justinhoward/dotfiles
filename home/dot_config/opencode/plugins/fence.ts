import { Plugin } from "@opencode/plugin"
import { spawnSync } from "node:child_process"
import { createHash } from "node:crypto"
import { mkdtempSync, realpathSync, rmSync, writeFileSync } from "node:fs"
import { tmpdir } from "node:os"
import { join, resolve } from "node:path"

/**
 * Fence sandbox integration for the V2 shell tool, plus history cleanup.
 *
 * This replaces the `@fencesandbox/opencode-fence` package, which only ships a
 * V1-plugin build (peer `@opencode-ai/plugin`) and so fails to load on V2 with
 * "Plugin must export a default definition with an id and an effect or setup
 * function". `fence hooks install --opencode` still writes that V1 package into
 * the config, so until Fence ships a V2 build this local plugin stands in for
 * it. The sandboxing half is a faithful port of that package (Apache-2.0,
 * https://github.com/fencesandbox/opencode-fence).
 *
 * Two halves, both keyed off the `fence [--settings ...] -c '...'` wrapper:
 *
 *  1. wrap (tool.execute.before): route each `shell` command through
 *     `fence --opencode-pre-tool-use`. Fence may deny it (the command is
 *     blocked), wrap it (rewrite to run inside `fence -c "..."`, inheriting
 *     Fence's filesystem/network policy), or allow it unchanged.
 *
 *  2. unwrap (session request hooks): hide that wrapper from the model's view
 *     of its own shell history, so it does not learn to copy `fence -c '...'`
 *     into new commands. Edits the outgoing request only; the command still
 *     runs wrapped. Calls with tool errors (including rejected agent-supplied
 *     Fence commands) retain their exact input so denials are not misleading.
 *
 * Linked worktrees keep their index/refs/objects in the original checkout's
 * Git directory. For those shells only, derive a policy from Fence's active
 * config and allow that project's shared Git metadata, not its source tree.
 * The derived policy keeps all existing denies and explicitly protects the
 * shared hooks/config, which are outside Fence's usual cwd-scoped protection.
 */

// ---------------------------------------------------------------------------
// Fence runner (ported from @fencesandbox/opencode-fence/fence-runner).
// ---------------------------------------------------------------------------

class FenceRunnerError extends Error {
  constructor(message: string, readonly cause?: unknown) {
    super(message)
    this.name = "FenceRunnerError"
  }
}

type FenceDecision =
  | { decision: "allow" }
  | { decision: "deny"; reason: string }
  | { decision: "wrap"; rewrittenCommand: string }

const FENCE_BINARY = "fence"
const FENCE_SUBCOMMAND = "--opencode-pre-tool-use"
const FENCE_TIMEOUT_MS = 5_000

type FenceRequest = {
  hook_event_name: "PreToolUse"
  tool_name: "Bash"
  tool_input: { command: string; cwd?: string }
}

function runFence(request: FenceRequest, settingsPath?: string): FenceDecision {
  const stdin = JSON.stringify(request)
  let result
  try {
    const args = settingsPath ? [FENCE_SUBCOMMAND, "--settings", settingsPath] : [FENCE_SUBCOMMAND]
    result = spawnSync(FENCE_BINARY, args, {
      input: stdin,
      // The shared V2 service's process.cwd() is not the session's directory.
      // Use the same cwd for config discovery and eventual shell execution.
      cwd: request.tool_input.cwd,
      encoding: "utf8",
      timeout: FENCE_TIMEOUT_MS,
      env: process.env,
    })
  } catch (err) {
    throw new FenceRunnerError(`Failed to invoke ${FENCE_BINARY}`, err)
  }

  if (result.error) {
    const code = (result.error as { code?: string }).code
    if (code === "ENOENT") {
      throw new FenceRunnerError(
        `Could not find the \`${FENCE_BINARY}\` executable on PATH. Install Fence ` +
          `(https://github.com/fencesandbox/fence).`,
        result.error,
      )
    }
    throw new FenceRunnerError(`Failed to invoke ${FENCE_BINARY}: ${result.error.message}`, result.error)
  }
  if (result.signal) {
    throw new FenceRunnerError(`${FENCE_BINARY} terminated by signal ${result.signal}`)
  }
  if (typeof result.status !== "number") {
    throw new FenceRunnerError(`${FENCE_BINARY} did not return an exit status`)
  }
  // Non-zero exit: treat as a Fence policy / runtime error. Surface the stderr
  // text rather than silently allowing the command.
  if (result.status !== 0) {
    const stderr = (result.stderr || "").trim()
    const stdout = (result.stdout || "").trim()
    const detail = stderr || stdout || `exit ${result.status}`
    throw new FenceRunnerError(`Fence hook helper failed: ${detail}`)
  }

  const stdout = (result.stdout || "").trim()
  if (stdout === "") {
    // No-op response: nothing to do (e.g. pure `cd`, already wrapped). Allow.
    return { decision: "allow" }
  }
  let parsed: { decision?: string; reason?: string; tool_input?: { command?: string } }
  try {
    parsed = JSON.parse(stdout)
  } catch (err) {
    throw new FenceRunnerError(`Fence returned non-JSON response: ${stdout.slice(0, 200)}`, err)
  }
  switch (parsed.decision) {
    case "deny":
      return { decision: "deny", reason: parsed.reason ?? "Command blocked by Fence policy." }
    case "wrap": {
      const rewritten = parsed.tool_input?.command
      if (!rewritten)
        throw new FenceRunnerError("Fence returned decision=wrap with no tool_input.command")
      return { decision: "wrap", rewrittenCommand: rewritten }
    }
    case "allow":
      return { decision: "allow" }
    default:
      throw new FenceRunnerError(`Fence returned unknown decision: ${JSON.stringify(parsed.decision)}`)
  }
}

// ---------------------------------------------------------------------------
// Linked-worktree policy (no global repo/path wildcard grants).
// ---------------------------------------------------------------------------

function gitDirectories(directory: string): { git: string; common: string } | undefined {
  const result = spawnSync("git", ["rev-parse", "--path-format=absolute", "--git-dir", "--git-common-dir"], {
    cwd: directory,
    encoding: "utf8",
    timeout: FENCE_TIMEOUT_MS,
    env: process.env,
  })
  if (result.status !== 0) return undefined
  const [git, common] = result.stdout.trim().split("\n")
  if (!git || !common) throw new Error("Cannot resolve Git directories for Fence.")
  return { git: realpathSync(git), common: realpathSync(common) }
}

function worktreeSettings(directory: string, canonical: string, policyDirectory: () => string): string | undefined {
  const dirs = gitDirectories(directory)
  if (!dirs || dirs.git === dirs.common) return undefined

  // An explicit shell workdir can point at a different repository. Never
  // grant its shared metadata using this project's plugin instance.
  const projectDirs = gitDirectories(canonical)
  if (!projectDirs || projectDirs.common !== dirs.common)
    throw new Error("Fence worktree metadata belongs to a different project.")

  // Ask Fence to resolve inheritance/JSONC rather than implementing a second
  // config loader. Inspect only; this does not execute the requested command.
  const result = spawnSync(FENCE_BINARY, ["config", "show"], {
    cwd: directory,
    encoding: "utf8",
    timeout: FENCE_TIMEOUT_MS,
    env: process.env,
  })
  if (result.status !== 0)
    throw new FenceRunnerError(`Cannot resolve Fence worktree policy: ${result.stderr?.trim() || result.error?.message || result.status}`)

  const config = JSON.parse(result.stdout)
  // `config show` has already flattened the inheritance chain.
  delete config.extends
  const filesystem = config.filesystem ??= {}
  filesystem.allowWrite = [...new Set([...(filesystem.allowWrite ?? []), dirs.common])]

  const protectedPaths = [join(dirs.common, "hooks")]
  if (!filesystem.allowGitConfig) {
    protectedPaths.push(
      join(dirs.common, "config"),
      join(dirs.common, "config.worktree"),
      join(dirs.common, "worktrees", "*", "config.worktree"),
    )
  }
  // Even though Fence normally allows temp writes, the shell must not be
  // able to alter the policy file or replace entries in its parent directory.
  const parent = policyDirectory()
  filesystem.denyWrite = [...new Set([...(filesystem.denyWrite ?? []), ...protectedPaths, parent])]
  const content = JSON.stringify(config)
  const digest = createHash("sha256").update(content).digest("hex")
  const path = join(parent, `${digest}.json`)
  writeFileSync(path, content, { mode: 0o600 })
  return path
}

// ---------------------------------------------------------------------------
// Unwrap helpers (hide the fence wrapper from the model's shell history).
// ---------------------------------------------------------------------------

const WRAPPED = /^(?:\S*\/)?fence(?: --settings (?:[^\s'\\]+|'[^']*'|\\.)+)? -c ('[\s\S]*)$/
// One shell token: a single-quoted segment, \' , or "'" .
const TOKEN = /'([^']*)'|\\'|"'"/y

const decode = (word: string): string | undefined => {
  let out = ""
  TOKEN.lastIndex = 0
  while (TOKEN.lastIndex < word.length) {
    const start = TOKEN.lastIndex
    const m = TOKEN.exec(word)
    if (!m || m.index !== start) return undefined
    out += m[1] ?? "'"
  }
  return out
}

const unwrap = (command: string): string | undefined => {
  const m = WRAPPED.exec(command)
  return m ? decode(m[1]) : undefined
}

// Request kinds whose outgoing messages should be unwrapped. The shell tool
// history appears in each one, so register the same transform on all of them.
const KINDS = ["context", "compaction", "generate", "title"] as const

export default Plugin.define({
  id: "fence",
  async setup(ctx) {
    let policyDirectory: string | undefined
    const getPolicyDirectory = () => policyDirectory ??= realpathSync(mkdtempSync(join(tmpdir(), "opencode-fence-")))

    // 1. Wrap each shell command through Fence before it runs.
    await ctx.tool.hook("execute.before", async (event) => {
      if (event.tool !== "shell") return
      const args = event.input as { command?: unknown; workdir?: unknown }
      const command = typeof args.command === "string" ? args.command : ""
      if (command.trim() === "") return
      const session = await ctx.session.get({ sessionID: event.sessionID })
      const cwd = typeof args.workdir === "string"
        ? resolve(session.location.directory, args.workdir)
        : session.location.directory
      // A child process cannot widen a whole-agent sandbox's existing policy.
      const settingsPath = process.env.FENCE_SANDBOX === "1"
        ? undefined
        : worktreeSettings(cwd, ctx.location.project.canonical, getPolicyDirectory)

      const result = runFence({
        hook_event_name: "PreToolUse",
        // Fence's helper still uses the Claude-shaped "Bash" protocol name.
        tool_name: "Bash",
        tool_input: { command, cwd },
      }, settingsPath)

      if (result.decision === "deny")
        throw new Error(`Fence denied this command: ${result.reason}`)

      if (result.decision === "wrap") {
        // Don't double-wrap when already running inside `fence -- opencode`.
        if (process.env.FENCE_SANDBOX === "1") return
        args.command = result.rewrittenCommand
      }
      // "allow" (or suppressed wrap): leave args.command alone.
    })

    // 2. Unwrap only completed calls with non-error results. Matching a wrapper
    // string alone cannot establish that it came from this plugin: rejected
    // agent-supplied `fence --settings ...` commands have the same syntax.
    for (const kind of KINDS) {
      await ctx.session.hook(kind, (event) => {
        const completed = new Set<string>()
        const failed = new Set<string>()
        for (const message of event.messages) {
          if (!Array.isArray(message.content)) continue
          for (const part of message.content as Array<Record<string, unknown>>) {
            if (part.type !== "tool-result" || part.name !== "shell" || typeof part.id !== "string") continue
            const result = part.result as { type?: unknown } | undefined
            if (result?.type === "error") failed.add(part.id)
            else if (result?.type === "text" || result?.type === "json" || result?.type === "content")
              completed.add(part.id)
          }
        }
        for (const message of event.messages) {
          if (!Array.isArray(message.content)) continue
          for (const part of message.content as Array<Record<string, unknown>>) {
            if (part.type !== "tool-call" || part.name !== "shell") continue
            if (typeof part.id !== "string" || !completed.has(part.id) || failed.has(part.id)) continue
            const input = part.input as { command?: unknown } | undefined
            if (typeof input?.command !== "string") continue
            const inner = unwrap(input.command)
            if (inner !== undefined) input.command = inner
          }
        }
      })
    }
    return () => {
      if (policyDirectory) rmSync(policyDirectory, { recursive: true, force: true })
    }
  },
})
