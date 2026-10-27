import { Plugin } from "@opencode/plugin"

export default Plugin.define({
  id: "wait",
  async setup(ctx) {
    await ctx.tool.transform((editor) => {
      editor.namespace({
        name: "wait",
        description: "Timed waits for use inside code-mode loops",
      })
      editor.add({
        name: "sleep",
        description: "Resolve after the given number of seconds (1-1800).",
        input: {
          type: "object",
          properties: { seconds: { type: "number", minimum: 1, maximum: 1800 } },
          required: ["seconds"],
          additionalProperties: false,
        },
        options: { namespace: "wait", codemode: true },
        execute: async (input, context) => {
          const { seconds } = input as { seconds: number }
          await new Promise<void>((resolve, reject) => {
            const timer = setTimeout(resolve, seconds * 1000)
            context.signal?.addEventListener("abort", () => {
              clearTimeout(timer)
              reject(new Error("wait aborted"))
            })
          })
          return { content: `waited ${seconds}s` }
        },
      })
    })
  },
})
