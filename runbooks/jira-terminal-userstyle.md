# Jira / terminal userstyle

The Jira companion to [GitHub / terminal](github-terminal-userstyle.md), for
Firefox + [Stylus](https://addons.mozilla.org/firefox/addon/styl-us/).

- The same **Sonokai dark / Everforest light** palette and **Victor Mono** font.
- Square corners, flat controls/cards, no shadows, and small monospace headings.
- 1px separators for board columns, cards, and tables, plus field/dialog
  boundaries and visible keyboard focus.
- Paired text/icon/background colors for selected controls, primary actions,
  status lozenges, messages, and tooltips.
- No hidden navigation/actions, fixed board widths, rearranged cards, or changes
  to drag/drop behavior. Configured card-color strips are not removed.

The style overrides Atlassian's `--ds-*` design tokens, rather than depending on
generated CSS class names. Accent colors are mapped into the terminal palette;
status categories remain distinct, but not every native accent shade is retained.
No fonts or other assets are fetched by the style.

## Install in Firefox

1. Disable any other Jira userstyles to avoid conflicts.
2. Press **Cmd+O** (macOS) or **Ctrl+O** (Linux) in Firefox and open
   `home/dot_config/stylus/jira-terminal.user.css` from this repo.
3. Click **Install style** in the Stylus installation tab.
4. Open Jira and refresh the page.

After `chezmoi apply`, the file is also available at
`~/.config/stylus/jira-terminal.user.css`. Chezmoi manages the file; installing
or updating the style in the extension is still a manual step.

If the installer doesn't open, use **Stylus → Manage → Write new style →
as UserCSS**, replace the editor contents with the whole file, and save.

## Appearance and settings

Use the gear icon next to **Jira / terminal** in Stylus:

- **Appearance:** follow the system (default), force Sonokai dark, or force
  Everforest light.
- **Font family:** a locally installed font or CSS font stack.
- **Text size:** 11–18px, default 13px.

Set Jira's own theme to **Match browser/system** too where available. The style
overrides token-based colors independently, but matching the native theme also
helps with hardcoded colors, logos, and embedded apps.

Requires Firefox 120+ for `light-dark()`.

## Scope and custom hosts

By default, this targets **Jira Cloud** on `*.atlassian.net`: the site root and
Jira routes under `/jira`, `/browse`, `/secure`, `/plugins/servlet`, `/projects`,
`/issues`, and `/servicedesk`. Confluence's `/wiki`, login pages, and standalone
Atlassian admin pages are excluded.

For a custom Jira hostname, add a condition to the existing `@-moz-document`
rule, separated by a comma:

```css
@-moz-document regexp("…existing expression…"), url-prefix("https://jira.example.com/") {
```

The theme is built for Cloud/Atlaskit. Adding a self-hosted Jira Data Center host
doesn't guarantee full coverage of its older AUI interface. Cross-origin app
iframes also remain outside the style's scope.

## Updating and checking

Reopen the file and choose **Reinstall style**, or enable **Live reload** in the
local installation tab and leave it open while editing the file externally.

The palette matches `github-terminal.user.css`. Jira's subdued colored surfaces
are tuned for readable text in both appearances, including inverse text/icons
on solid buttons and badges.

Check boards, backlog, issue details and editing, status/priority labels, create
dialogs, dropdowns, tooltips, and keyboard focus after edits. Jira has multiple
UI generations; semantic tokens cover modern screens, and the board selectors
may need adjustment when Atlassian changes its markup. Rendering in a logged-in
Jira session has not been verified in the sandbox.
