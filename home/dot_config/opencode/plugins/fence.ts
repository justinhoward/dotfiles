import { Plugin } from "@opencode/plugin"
import { spawnSync } from "node:child_process"

/**
 * Fence sandbox integration for the bash tool, plus history cleanup.
 *
 * This replaces the `@fencesandbox/opencode-fence` package, which only ships a
 * V1-plugin build (peer `@opencode-ai/plugin`) and so fails to load on V2 with
 * "Plugin must export a default definition with an id and an effect or setup
 * function". `fence hooks install --opencode` still writes that V1 package into
 * the config, so until Fence ships a V2 build this local plugin stands in for
 * it. The sandboxing half is a faithful port of that package (Apache-2.0,
 * https://github.com/fencesandbox/opencode-fence).
 *
 * Two halves, both keyed off the same `fence -c '...'` wrapper:
 *
 *  1. wrap (tool.execute.before): route each `bash` command through
 *     `fence --opencode-pre-tool-use`. Fence may deny it (the command is
 *     blocked), wrap it (rewrite to run inside `fence -c "..."`, inheriting
 *     Fence's filesystem/network policy), or allow it unchanged.
 *
 *  2. unwrap (session request hooks): hide that wrapper from the model's view
 *     of its own bash history, so it does not learn to copy `fence -c '...'`
 *     into new commands. Edits the outgoing request only; the command still
 *     runs wrapped.
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

function runFence(request: FenceRequest): FenceDecision {
  const stdin = JSON.stringify(request)
  let result
  try {
    result = spawnSync(FENCE_BINARY, [FENCE_SUBCOMMAND], {
      input: stdin,
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
// Unwrap helpers (hide the fence wrapper from the model's bash history).
// ---------------------------------------------------------------------------

const WRAPPED = /^(?:\S*\/)?fence -c ('[\s\S]*)$/
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

// Request kinds whose outgoing messages should be unwrapped. The bash tool
// history appears in each one, so register the same transform on all of them.
const KINDS = ["context", "compaction", "generate", "title"] as const

export default Plugin.define({
  id: "fence",
  async setup(ctx) {
    // 1. Wrap each bash command through Fence before it runs.
    await ctx.tool.hook("execute.before", (event) => {
      if (event.tool !== "bash") return
      const args = event.input as { command?: unknown; cwd?: unknown }
      const command = typeof args.command === "string" ? args.command : ""
      if (command.trim() === "") return
      const cwd = typeof args.cwd === "string" ? args.cwd : undefined

      const result = runFence({
        hook_event_name: "PreToolUse",
        tool_name: "Bash",
        tool_input: cwd === undefined ? { command } : { command, cwd },
      })

      if (result.decision === "deny")
        throw new Error(`Fence denied this command: ${result.reason}`)

      if (result.decision === "wrap") {
        // Don't double-wrap when already running inside `fence -- opencode`.
        if (process.env.FENCE_SANDBOX === "1") return
        args.command = result.rewrittenCommand
      }
      // "allow" (or suppressed wrap): leave args.command alone.
    })

    // 2. Unwrap the fence wrapper from the model's view of its bash history.
    for (const kind of KINDS) {
      await ctx.session.hook(kind, (event) => {
        for (const message of event.messages) {
          if (!Array.isArray(message.content)) continue
          for (const part of message.content as Array<Record<string, unknown>>) {
            if (part.type !== "tool-call" || part.name !== "bash") continue
            const input = part.input as { command?: unknown } | undefined
            if (typeof input?.command !== "string") continue
            const inner = unwrap(input.command)
            if (inner !== undefined) input.command = inner
          }
        }
      })
    }
  },
})
