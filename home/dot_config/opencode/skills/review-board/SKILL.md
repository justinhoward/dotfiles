---
name: review-board
description: "Use ONLY when the user explicitly requests a deep, board, or expert review of code changes (e.g. 'board review', 'run the review board', 'expert review this PR', 'deep review my changes', 'thorough review of this architecture'). Convenes parallel expert personas — Architect, Security, Testing, Type Design, Performance, UX/Accessibility — and curates their findings as the code author with accept/acknowledge/dismiss recommendations. Do not trigger for ordinary code review or general questions."
---

# review-board — Expert Review Board

Convene six expert personas as parallel subagents, then curate their findings from the author's perspective into a severity-ranked report. This is for high-stakes changes — architecture, security-sensitive code, large refactors, new subsystems — where judgment-heavy scrutiny matters, not a checklist.

Persona prompt templates live in `personas/` alongside this file. This is a thorough review: dispatch all six personas and give the changed code real scrutiny — don't skim or skip meaningful changes. Use judgment on noise (lockfiles, generated code, snapshots, vendored deps) rather than reading everything line by line.

## 1) Guard and gather

- Confirm you're in a git repo. If not, stop and say so.
- Determine the base to diff against: the default branch (`main`/`master`), preferring `origin/<branch>` if fetched, else the local branch or `git merge-base`. If there are no changes versus the base, tell the user there's nothing to review and stop.
- Get the diff and the changed-file list. If the diff is very large, summarize the biggest files (stat only) and send full diffs for the rest.

## 2) Dispatch persona subagents

Read the persona templates from `personas/` (`architect.md`, `security.md`, `testing.md`, `type-design.md`, `performance.md`, `ux-accessibility.md`). Dispatch one `task` subagent (`subagent_type: general`) per persona, all in a **single parallel batch** (one message, multiple calls). If a subagent fails or returns nothing, mark that persona skipped and continue.

Each subagent prompt should contain the persona template, the diff, the file list, and this return contract:

> You are a {persona} reviewing this diff. Analyze only — do not modify files. For each finding, return:
>
> ```
> ### [TITLE]
> - severity: critical | warning | suggestion | positive
> - file / line_range: (or "general" for cross-cutting concerns)
> - rationale: expert reasoning — why it matters, what breaks. Specific, for an experienced audience.
> - suggestion: concrete action.
> ```
>
> Stay within your expertise; don't duplicate other personas. Prefer few high-quality findings over many shallow ones. Include at most 2 positives. Skip style/naming/formatting nits.
> - critical: bugs, security holes, data loss, or major UX failures in production.
> - warning: should be fixed but won't immediately break.
> - suggestion: improvement, not a defect.
> - positive: a well-done pattern worth calling out.

## 3) Curate as the author

Collect all findings. Merge duplicates (same location + overlapping concern) into one finding crediting both personas at the higher severity. Then, as the developer who wrote this code, assign each a recommendation:

- **Accept** — valid, should be addressed. Note "fix before merge" or "follow-up".
- **Acknowledge** — valid but acceptable given a stated constraint.
- **Dismiss** — you disagree; give a concrete reason (not "this is fine").

Lean toward Accept for critical/warning findings. Positives get no recommendation. Base judgments on the actual code, not just the finding text.

## 4) Report

Produce a report ordered by severity (critical first):

```
# Review Board: <branch>

<1-2 sentence overall assessment.>

## Board Summary

| # | Reviewer | Severity | Finding | Author Recommendation |
|---|----------|----------|---------|----------------------|
| 1 | Security + Architect | critical | ... | Accept — fix before merge |

## Detailed Findings

### 1. [Title]
**Reviewer**: {persona} · **Severity**: {level} · **Location**: `{file}` L{range}
**Analysis**: {the persona's expert reasoning — the real value}
**Suggestion**: {concrete action}
**Author recommendation**: {Accept/Acknowledge/Dismiss} — {rationale}

## Board Composition
<one line per persona: findings count and Completed / Skipped>
```

Show detailed findings for accept and acknowledge items; dismissed items appear in the summary table only.

## 5) Follow up

Use the `question` tool to offer: expand on a finding, generate fixes, or re-review after changes. If the user picks expand or fix and there are several findings, ask which one first.
