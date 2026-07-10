import type { Plugin } from "@opencode-ai/plugin"

/**
 * Lazy AWS Identity Center (SSO) login for the amazon-bedrock provider.
 *
 * opencode's `amazon-bedrock` provider (see opencode.json) authenticates with
 * the AWS profile below, which uses an SSO session. When that SSO session
 * expires, Bedrock calls fail with an auth error.
 *
 * Rather than checking at startup, this hooks `chat.params` — which fires just
 * before each request is sent to a provider — and only acts when the request
 * is actually going to the Bedrock provider. On the first such request it
 * checks the profile's credentials and, only if they are missing/expired, runs
 * `aws sso login` to open the AWS Identity Center login in your browser. The
 * hook is awaited, so the request waits until login completes.
 *
 * The check/login runs at most once per opencode process (subsequent Bedrock
 * requests reuse the same in-flight/completed result). If a login attempt
 * fails, the next Bedrock request will try again.
 *
 * Override the profile with the OPENCODE_AWS_PROFILE env var if needed.
 */
const AWS_PROFILE = process.env.OPENCODE_AWS_PROFILE ?? "psai"
const BEDROCK_PROVIDER = "amazon-bedrock"

export const AwsSsoLogin: Plugin = async ({ $, client }) => {
  const log = (level: "info" | "warn" | "error", message: string) =>
    client.app
      .log({ body: { service: "aws-sso-login", level, message } })
      .catch(() => {})

  // Shared guard so concurrent Bedrock requests await a single login, and a
  // successful result is cached for the rest of the process.
  let inflight: Promise<void> | null = null

  const ensureSso = async () => {
    // Skip silently if the AWS CLI isn't installed.
    const awsCheck = await $`command -v aws`.nothrow().quiet()
    if (awsCheck.exitCode !== 0) return

    // Validity check. Uses the cached SSO token to (re)fetch role credentials
    // without a browser; exits non-zero only when the SSO session itself is
    // expired or the profile has no usable credentials.
    const check =
      await $`aws sts get-caller-identity --profile ${AWS_PROFILE} --cli-connect-timeout 5 --cli-read-timeout 10 --output text`
        .nothrow()
        .quiet()
    if (check.exitCode === 0) return

    await log(
      "info",
      `AWS profile "${AWS_PROFILE}" has no valid credentials; opening AWS Identity Center login...`,
    )
    // Foreground: the AWS CLI opens the browser and waits for you to finish.
    // Let this throw on failure so the guard below can allow a retry.
    // .quiet() captures the CLI's output instead of writing it to the terminal,
    // which would otherwise corrupt opencode's TUI (overlapping the input box).
    await $`aws sso login --profile ${AWS_PROFILE}`.quiet()
    await log("info", `aws sso login for "${AWS_PROFILE}" completed.`)
  }

  const ensureOnce = () => {
    if (!inflight) {
      inflight = ensureSso().catch(async (err) => {
        // Reset so a later Bedrock request can retry after a failed login.
        inflight = null
        await log(
          "error",
          `aws sso login for "${AWS_PROFILE}" failed: ${String(err)}`,
        )
      })
    }
    return inflight
  }

  return {
    "chat.params": async (input) => {
      const isBedrock =
        input.provider?.info?.id === BEDROCK_PROVIDER ||
        input.model?.providerID === BEDROCK_PROVIDER
      if (isBedrock) await ensureOnce()
    },
  }
}

export default AwsSsoLogin
