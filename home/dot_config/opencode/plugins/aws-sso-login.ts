import { Plugin } from "@opencode/plugin"

/**
 * Lazy AWS Identity Center (SSO) login for the amazon-bedrock provider.
 *
 * opencode's `amazon-bedrock` provider (see opencode.jsonc) authenticates with
 * the AWS profile below, which uses an SSO session. When that SSO session
 * expires, Bedrock calls fail with an auth error.
 *
 * Rather than checking at startup, this hooks the session request hooks —
 * which fire just before each request is sent to a provider — and only acts
 * when the request is actually going to the Bedrock provider. When the
 * profile's cached credentials are missing or expired it runs `aws sso login`
 * to open the AWS Identity Center login in your browser. The hook is awaited,
 * so the request waits until login completes.
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
 * That pre-request check can't be fully trusted, though. The CLI answers from
 * its own role-credential cache (~/.aws/cli/cache) while those credentials
 * last, even after the SSO session behind them has expired or been revoked.
 * opencode's embedded AWS JS SDK never reads that cache: it keeps its own
 * in-memory role credentials and, when they lapse, mints new ones from the SSO
 * token (~/.aws/sso/cache). So the CLI can report "valid for hours" while
 * Bedrock fails with an expired-SSO-session error. To recover from that, a
 * `retry` hook watches for credential failures from Bedrock, forces
 * `aws sso login` (skipping the probe, which would wrongly report success),
 * and retries the request.
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
// After a forced login, don't open another browser login for this long; if
// Bedrock still rejects the credentials, the problem isn't an expired session.
const RELOGIN_COOLDOWN_MS = 2 * 60_000

// Bedrock or AWS SDK errors meaning the credentials are expired or unusable,
// as opposed to authorization failures such as AccessDenied, which a new login
// won't fix.
const CREDENTIAL_ERROR =
  /SSO session|Token is expired|ExpiredToken|security token included in the request is (expired|invalid)|UnrecognizedClient|Could not load credentials|aws sso login/i

// Request kinds that issue a provider call. Each is gated the same way.
const KINDS = ["context", "generate", "title", "compaction"] as const

export default Plugin.define({
  id: "aws-sso-login",
  async setup(ctx) {
    const $ = Bun.$
    const log = (level: "info" | "warn" | "error", message: string) => {
      const line = `[aws-sso-login] ${message}`
      if (level === "error") console.error(line)
      else if (level === "warn") console.warn(line)
      else console.log(line)
    }

    // Shared guard so concurrent Bedrock requests await a single login, and a
    // successful result is cached until the credentials are about to expire.
    let inflight: Promise<void> | null = null
    // Epoch ms until which credentials are known-good; 0 forces a re-check.
    let validUntil = 0

    // Run `aws sso login` (opens the browser) and wait for it to finish.
    // .quiet() captures the CLI's output instead of writing it to the terminal,
    // which would otherwise corrupt opencode's TUI (overlapping the input box).
    const ssoLogin = async () => {
      log(
        "info",
        `AWS profile "${AWS_PROFILE}" has no valid credentials; opening AWS Identity Center login...`,
      )
      await $`aws sso login --profile ${AWS_PROFILE}`.quiet()
      log("info", `aws sso login for "${AWS_PROFILE}" completed.`)
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

    // Bedrock rejected credentials the CLI considers valid: log in
    // unconditionally, then re-probe for the new expiry.
    const relogin = async () => {
      validUntil = 0
      await ssoLogin()
      const probe = await probeExpiry()
      if (!probe.ok)
        throw new Error("credentials still invalid after aws sso login")
      validUntil =
        probe.expiresAt !== null
          ? probe.expiresAt - EXPIRY_SAFETY_MS
          : Date.now() + FALLBACK_TTL_MS
    }

    // Run one check/login at a time. Returns whether it succeeded.
    const serialize = async (task: () => Promise<void>) => {
      while (inflight) await inflight
      let ok = true
      inflight = task()
        .catch((err) => {
          ok = false
          // Reset so a later Bedrock request can retry after a failed login.
          log(
            "error",
            `aws sso login for "${AWS_PROFILE}" failed: ${String(err)}`,
          )
        })
        .finally(() => {
          inflight = null
        })
      await inflight
      return ok
    }

    const ensureFresh = async () => {
      // Fast path: credentials known-good, skip the CLI entirely.
      if (Date.now() < validUntil) return
      if (inflight) return inflight
      await serialize(ensureSso)
    }

    for (const kind of KINDS) {
      await ctx.session.hook(kind, async (event) => {
        if (event.model?.providerID === BEDROCK_PROVIDER) await ensureFresh()
      })
    }

    let lastRelogin = 0
    await ctx.session.hook(
      "retry",
      async (event) => {
        if (!CREDENTIAL_ERROR.test(`${event.error.type} ${event.error.message}`))
          return
        if (Date.now() - lastRelogin < RELOGIN_COOLDOWN_MS) return
        lastRelogin = Date.now()
        log(
          "warn",
          `Bedrock rejected credentials for "${AWS_PROFILE}": ${event.error.message}`,
        )
        if (await serialize(relogin)) event.decision = { retry: true, delay: 0 }
      },
      { providerID: BEDROCK_PROVIDER },
    )
  },
})
