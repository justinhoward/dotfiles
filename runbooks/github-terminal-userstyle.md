# GitHub / terminal userstyle

A Firefox + [Stylus](https://addons.mozilla.org/firefox/addon/styl-us/) style
matching the terminal/editor setup:

- **Dark:** Sonokai (`#2c2e34` background, `#e2e2e3` text).
- **Light:** Everforest hard (`#fffbef` background, `#5c6a72` text).
- **Font:** locally installed Victor Mono, with Nerd Font / monospace fallbacks.
- Square corners and avatars, no shadows or gradients on controls, flat cards,
  bracketed counters, and small monospace document headings.
- 1px separators, input/dialog boundaries, and keyboard-focus outlines. Diff
  backgrounds, syntax colors, issue labels, status indicators, navigation,
  sidebars, and repository/review actions remain intact.

Light-mode accent colors are darker variations of the terminal palette so links
and status text remain readable against the cream background. No fonts or other
assets are fetched by the style.

## Install in Firefox

1. Install Stylus and disable any other GitHub styles to avoid conflicts.
2. Open `home/dot_config/stylus/github-terminal.user.css` from this repo in
   Firefox using **Cmd+O** (macOS) or **Ctrl+O** (Linux).
3. Stylus opens an installation tab. Click **Install style**.
4. Visit `https://github.com`.

After `chezmoi apply`, the same file is available at
`~/.config/stylus/github-terminal.user.css`. Chezmoi manages the CSS file, not
the extension's database; installation in Stylus is still a manual step.

If Firefox shows plain text instead of the installer: open **Stylus → Manage →
Write new style**, enable **as UserCSS**, replace the entire editor contents with
the file (including its metadata header), and save.

## Settings

Open the gear icon next to **GitHub / terminal** in Stylus:

- **Appearance:** follow the system (default), force Sonokai dark, or force
  Everforest light. This overrides GitHub's account theme; for the closest match
  on theme-dependent elements such as issue labels, set GitHub's appearance to
  **Sync with system** too.
- **Font family:** any locally installed monospace font or CSS font stack.
- **Text size:** 11–18px, default 13px. Browser zoom still works normally.

Requires a current Firefox with `light-dark()` support (Firefox 120+).
The style is scoped to `https://github.com/`, not GitHub Enterprise hosts or
Gist. To include another host, add a `domain("your-host")` condition to
the `@-moz-document` rule.

## Editing / updating

The palette is at the top of the file. Each `light-dark(light, dark)` pair lists
Everforest first and Sonokai second. Most coloring overrides GitHub's semantic
Primer tokens rather than hardcoded colors on individual elements.

Reopen the local file and choose **Reinstall style** after editing it. For an
immediate preview, enable **Live reload** in Stylus' local-file installation tab
and leave that tab open while editing the file externally.

GitHub's UI changes frequently. Check repository files, README rendering,
issues, pull-request diffs, dropdowns/dialogs, keyboard focus, and narrow layouts
after changing selectors. React selector fragments intentionally omit generated
hashes, but may still need updates when GitHub renames components.
