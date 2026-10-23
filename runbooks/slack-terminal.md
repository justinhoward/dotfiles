# Slack / terminal

A local CSS theme and small, dependency-free launcher/watcher for the **native
Slack desktop app on macOS**. It keeps the vendor-signed app, updater, Dock icon,
unread badge, notifications, and huddle features. No app-bundle modifications,
AI/agent features, npm runtime packages, background-throttling flags, screenshots,
message inspection, or token/cookie access.

Requires **Node 22+**. The theme matches the GitHub/Jira/Firefox themes: Sonokai
dark, Everforest light, Victor Mono, square geometry, and essential 1px borders.
Set Slack's **Preferences → Appearance → Color Mode → System** for the best match.

## First test, before installing

1. Quit Slack normally with **Cmd+Q**, after finishing any huddle or unsent work.
2. In your own Terminal, run:

   ```sh
   controller="$HOME/.dotfiles/home/dot_config/slack-terminal"
   node "$controller/executable_slack-terminal.mjs" launch
   ```

3. After Slack loads, check:

   ```sh
   node "$controller/executable_slack-terminal.mjs" status
   ```

   Expect `phase: "attached"`, `applied` greater than zero, and no error. `sample`
   reports only background/foreground colors, font, and font size—not chat data.

4. Check channel navigation, threads, composer, selected items, tooltips, unread
   indicators, Dock badge, notifications, and huddles. Toggle system appearance
   and edit the CSS to check theme switching and reload. A brief flash of Slack's
   original theme during startup/reload is possible.

The OpenCode sandbox cannot inspect desktop processes here, so this live test
must be initiated in your Terminal. The files can be tested directly from the
repo; you don't need to install or change your active skhd configuration first.

## Install / launch

Chezmoi installs the source directory `home/dot_config/slack-terminal/` to
`~/.config/slack-terminal/`, and the wrapper to
`~/.config/skhd/scripts/slack_terminal.sh`. To apply only this setup, without
running setup scripts or deploying other pending themes:

```sh
chezmoi diff --recursive --exclude=scripts \
  ~/.config/slack-terminal \
  ~/.config/skhd/scripts/slack_terminal.sh ~/.config/skhd/skhdrc
chezmoi apply --recursive --exclude=scripts \
  ~/.config/slack-terminal \
  ~/.config/skhd/scripts/slack_terminal.sh ~/.config/skhd/skhdrc
```

The repo's **app mode → s** skhd binding uses the wrapper, preserving the
existing mode-exit behavior. After installation, quit Slack normally and
relaunch through that shortcut to switch from the repo's test stylesheet to
the installed `~/.config/slack-terminal/slack-terminal.css` copy.

- If Slack is closed, the wrapper starts the real Slack executable with a
  **loopback-only, dynamically allocated DevTools port**, then a CSS watcher.
- If Slack is running, it **focuses it without quitting or opening duplicates**.
- If Slack was started normally from the Dock, it is left running normally.
  Quit/relaunch through the wrapper when you want styling.
- If an owned watcher crashes while its managed Slack process remains running,
  the next launch can resume the watcher without restarting Slack.
- If Node/the controller isn't installed, or the launcher fails, the shell
  wrapper falls back to a normal Slack launch/focus.

The default app is `/Applications/Slack.app`. Override it with
`SLACK_TERMINAL_APP` or `--app /path/to/Slack.app` if needed.

## Edit / control

```sh
node ~/.config/slack-terminal/slack-terminal.mjs status
node ~/.config/slack-terminal/slack-terminal.mjs disable
node ~/.config/slack-terminal/slack-terminal.mjs enable
node ~/.config/slack-terminal/slack-terminal.mjs stop
```

- **disable:** remove the theme from managed windows and persist the off setting.
  While disabled, a future cold launch uses normal Slack without debugging.
- **enable:** reapply the theme if the watcher is attached. Otherwise, quit Slack
  normally and launch through the wrapper to start a managed session.
- **stop:** clear the theme and stop the watcher, without quitting Slack. A later
  launch can resume it. If cleanup can't reach a renderer, reload/quit normally.

Edits to `slack-terminal.css` apply within about two seconds. Normal renderer
reloads and new Slack client windows are rediscovered. Invalid/imported-asset
edits leave the last valid theme intact; disabling/stopping still clears it.
Only local CSS is accepted: imported styles and URL assets are rejected. Fonts
must already be installed locally. Local CSS is trusted input, not a sandbox for
third-party themes.

Runtime metadata and logs live under
`${XDG_STATE_HOME:-~/.local/state}/slack-terminal/`, with a private directory and
files. `session.json` contains process/port metadata and style samples;
`watcher.log` contains diagnostic errors, not messages or screenshots.
`SLACK_TERMINAL_CSS` / `--css` selects another CSS file; the selection takes effect
on a new/resumed watcher, not an already-running watcher.

## Important limitations

**Debugging access is broader than CSS.** The watcher verifies that the listening
port belongs to the launched Slack process and is bound only to loopback before
connecting. It rejects foreign/non-loopback debugger endpoints. However, other
local processes may still use that DevTools port to access your Slack session.
Use this only on a trusted machine and if workspace policies permit it.

**Stopping the watcher doesn't close Slack's debugging port.** To remove that
access, quit Slack completely, then start it normally or leave styling disabled.
The launcher never silently quits Slack, disables CSP, changes its security
fuses, disables background throttling, or disables updates.

**Dock cold launches and updater relaunches can bypass the wrapper.** Native
features still work, but the theme may be absent until a managed relaunch. No
login item is installed automatically; if desired, configure the same wrapper
as your login launcher instead of Slack's ordinary login item.

**CSS selectors can change.** Styling should be verified against Slack updates;
this is an unsupported customization, not an official Slack extension API.

## Tests

```sh
node --test tests/slack-terminal.test.mjs
```

Tests use fake process operations, a fake DevTools socket and a minimal DOM.
They never launch/quit Slack or inspect real messages.
