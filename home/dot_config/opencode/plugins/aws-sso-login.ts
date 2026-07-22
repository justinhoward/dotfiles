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
 * is actually going to the Bedrock provider. When the profile's cached
 * credentials are missing or expired it runs `aws sso login` to open the AWS
 * Identity Center login in your browser. The hook is awaited, so the request
 * waits until login completes.
 *
 * Validity is derived from the AWS CLI itself rather than guessed: a single
 * `aws configure export-credentials` call both proves the credentials resolve
 * (non-zero exit means the SSO session is expired/invalid → browser login) and
 * returns their real `Expiration`. That expiry (minus a safety margin) is
 * cached in `validUntil`, so subsequent Bedrock requests skip the CLI entirely
 * until the credentials are actually about to lapse. This lets a long-running
 * opencode process self-heal when an old session is resumed after the
 * credentials have expired — the previous version cached success for the whole
 * process lifetime and would then hand Bedrock an expired token.
 *
 * Because role credentials (~1h) are silently refreshed from the SSO session
 * (~8h) without a browser, re-checking near expiry usually just refreshes
 * quietly; a browser login is only triggered once the SSO session itself is
 * gone. If `export-credentials` is unavailable (older AWS CLI) or returns no
 * parseable expiry, it falls back to an `aws sts get-caller-identity` check
 * cached for a short default window.
 *
 * Concurrent Bedrock requests await a single in-flight check/login. If an
 * attempt fails, the next Bedrock request will try again.
 *
 * Override the profile with the OPENCODE_AWS_PROFILE env var if needed.
 */
const AWS_PROFILE = process.env.OPENCODE_AWS_PROFILE ?? "psai"
const BEDROCK_PROVIDER = "amazon-bedrock"

// Re-check slightly before the real expiry so a request never races a token
// that lapses in-flight.
const EXPIRY_SAFETY_MS = 60_000
// Cache window used only when the CLI can't tell us a real expiry (older CLI,
// or missing/unparseable Expiration). Keeps behavior sane without a signal.
const FALLBACK_TTL_MS = 15 * 60_000

export const AwsSsoLogin: Plugin = async ({ $, client }) => {
  const log = (level: "info" | "warn" | "error", message: string) =>
    client.app
      .log({ body: { service: "aws-sso-login", level, message } })
      .catch(() => {})

  // Shared guard so concurrent Bedrock requests await a single login, and a
  // successful result is cached until the credentials are about to expire.
  let inflight: Promise<void> | null = null
  // Epoch ms until which credentials are known-good; 0 forces a re-check.
  let validUntil = 0

  // Run `aws sso login` (opens the browser) and wait for it to finish.
  // .quiet() captures the CLI's output instead of writing it to the terminal,
  // which would otherwise corrupt opencode's TUI (overlapping the input box).
  const ssoLogin = async () => {
    await log(
      "info",
      `AWS profile "${AWS_PROFILE}" has no valid credentials; opening AWS Identity Center login...`,
    )
    await $`aws sso login --profile ${AWS_PROFILE}`.quiet()
    await log("info", `aws sso login for "${AWS_PROFILE}" completed.`)
  }

  // Resolve the profile's credentials and, on success, return the epoch ms at
  // which they expire (or null when no parseable Expiration is available).
  // A non-zero exit means the SSO session is expired/invalid.
  const probeExpiry = async (): Promise<
    { ok: true; expiresAt: number | null } | { ok: false }
  > => {
    const res =
      await $`aws configure export-credentials --profile ${AWS_PROFILE}`
        .nothrow()
        .quiet()
    if (res.exitCode !== 0) return { ok: false }
    try {
      const parsed = Date.parse(JSON.parse(res.stdout.toString()).Expiration)
      return { ok: true, expiresAt: Number.isNaN(parsed) ? null : parsed }
    } catch {
      return { ok: true, expiresAt: null }
    }
  }

  const ensureSso = async () => {
    // Skip silently if the AWS CLI isn't installed.
    const awsCheck = await $`command -v aws`.nothrow().quiet()
    if (awsCheck.exitCode !== 0) return

    let probe = await probeExpiry()

    // Older AWS CLI without `configure export-credentials`: fall back to a
    // get-caller-identity validity check cached for a short default window.
    if (!probe.ok) {
      const help = await $`aws configure export-credentials help`
        .nothrow()
        .quiet()
      if (help.exitCode !== 0) {
        const isValid = async () =>
          (
            await $`aws sts get-caller-identity --profile ${AWS_PROFILE} --cli-connect-timeout 5 --cli-read-timeout 10 --output text`
              .nothrow()
              .quiet()
          ).exitCode === 0
        if (!(await isValid())) {
          await ssoLogin()
          // Let a still-invalid session throw so it's logged and retried
          // rather than cached as good.
          if (!(await isValid()))
            throw new Error("credentials still invalid after aws sso login")
        }
        validUntil = Date.now() + FALLBACK_TTL_MS
        return
      }
    }

    // Real signal available: log in if needed, then re-probe.
    if (!probe.ok) {
      await ssoLogin()
      probe = await probeExpiry()
      // Still failing after login: throw to log + retry, don't cache.
      if (!probe.ok)
        throw new Error("credentials still invalid after aws sso login")
    }

    // Cache until the real expiry, or a short window if none was parseable.
    validUntil =
      probe.expiresAt !== null
        ? probe.expiresAt - EXPIRY_SAFETY_MS
        : Date.now() + FALLBACK_TTL_MS
  }

  const ensureFresh = () => {
    // Fast path: credentials known-good, skip the CLI entirely.
    if (Date.now() < validUntil) return Promise.resolve()
    if (!inflight) {
      inflight = ensureSso()
        .catch(async (err) => {
          // Reset so a later Bedrock request can retry after a failed login.
          await log(
            "error",
            `aws sso login for "${AWS_PROFILE}" failed: ${String(err)}`,
          )
        })
        .finally(() => {
          inflight = null
        })
    }
    return inflight
  }

  return {
    "chat.params": async (input) => {
      const isBedrock =
        input.provider?.info?.id === BEDROCK_PROVIDER ||
        input.model?.providerID === BEDROCK_PROVIDER
      if (isBedrock) await ensureFresh()
    },
  }
}

export default AwsSsoLogin
