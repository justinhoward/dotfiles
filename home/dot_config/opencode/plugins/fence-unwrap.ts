import type { Plugin } from "@opencode-ai/plugin"

/**
 * Hide the Fence wrapper from the model's view of its own bash history.
 *
 * The opencode-fence plugin sandboxes each bash call by rewriting
 * `args.command` in place to `/opt/homebrew/bin/fence -c '<command>'`.
 * OpenCode stores that rewritten input as the tool call, so on later turns
 * the model sees calls it never wrote. Models then copy the wrapper into
 * new commands, or apologise for "wrapping commands in fence" even though
 * AGENTS.md says not to.
 *
 * This hook runs on the copy of the history that is about to be sent to
 * the model (and on the copy used for compaction). It does not change
 * what is stored or what the UI shows, and it does not affect sandboxing:
 * the command still runs wrapped.
 *
 * Agent-written wrappers (`fence -c '...'` typed by the model, which Fence
 * accepts as already wrapped) are unwrapped too, since they reinforce the
 * same habit.
 *
 * The argument to -c is decoded exactly as sh would, but only when it is
 * built from single-quoted segments joined by an escaped quote (\' , "'" ,
 * or the plugin's '"'"'). Anything else is left alone.
 */

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

export const FenceUnwrap: Plugin = async () => ({
  "experimental.chat.messages.transform": async (_input, output) => {
    for (const message of output.messages) {
      for (const part of message.parts) {
        if (part.type !== "tool" || part.tool !== "bash") continue
        const input = part.state.input as { command?: unknown } | undefined
        if (typeof input?.command !== "string") continue
        const inner = unwrap(input.command)
        if (inner !== undefined) input.command = inner
      }
    }
  },
})

export default FenceUnwrap
