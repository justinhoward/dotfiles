#!/usr/bin/env bash
# Shellcheck the shell that ludeeus/action-shellcheck can't reach on its own:
#   1. the extensionless entry files (~/.bashrc etc. have neither a shebang nor
#      a .sh extension, so the action's file discovery skips them)
#   2. the *.sh.tmpl chezmoi templates — raw they contain Go template syntax
#      that isn't valid shell, so each is rendered first, then checked
#
# Run from the repository root; requires chezmoi and shellcheck on PATH. The OS
# branch chezmoi renders reflects the runner (Linux in CI, so the Linux arms of
# each template get checked); macOS-only templates render empty there and vice
# versa, which shellcheck treats as a clean no-op.
set -euo pipefail

fail=0

# 1. Extensionless entry files.
for f in home/dot_bashrc home/dot_bash_profile home/dot_profile; do
  echo "== shellcheck $f =="
  shellcheck -x "$f" || fail=1
done

# 2. Rendered templates. Render into the repo tree (not $TMPDIR) so shellcheck
# discovers the repo .shellcheckrc, then remove each temp file. mktemp is given
# an explicit template so it stays portable across GNU and BSD.
rendered=""
# Invoked via the EXIT trap below (SC2329: not a dead function). Capture and
# restore $? so the cleanup itself never rewrites the script's exit status —
# bash's EXIT trap otherwise lets the trap's last-command status leak through.
# shellcheck disable=SC2329
cleanup() {
  local ec=$?
  [ -n "$rendered" ] && rm -f "$rendered"
  return "$ec"
}
trap cleanup EXIT

while IFS= read -r f; do
  echo "== render + shellcheck $f =="
  rendered="$(mktemp "$PWD/ci-render.XXXXXX")"
  chezmoi execute-template --source home < "$f" > "$rendered"
  # Rendered run_* scripts carry a shebang (auto-detected); the sourced env /
  # rc.d fragments don't, so tell shellcheck they're POSIX sh.
  if head -n1 "$rendered" | grep -q '^#!'; then
    shellcheck -x "$rendered" || fail=1
  else
    shellcheck -x -s sh "$rendered" || fail=1
  fi
  rm -f "$rendered"
  rendered=""
done < <(git ls-files '*.sh.tmpl')

exit "$fail"
