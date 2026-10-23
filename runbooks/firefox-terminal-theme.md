# Firefox / terminal

A browser-UI companion to the [GitHub](github-terminal-userstyle.md) and
[Jira](jira-terminal-userstyle.md) themes: Sonokai dark, Everforest light, Victor
Mono, square corners, no shadows, and essential 1px borders.

This is **not a Stylus style**. Stylus cannot theme Firefox's tabs, address bar,
or browser menus. Firefox loads these files from the active profile's `chrome/`
directory when custom profile stylesheets are enabled.

## Files

Source: `home/dot_config/firefox/chrome/`.

- `userChrome.css` — tabs, toolbar, address-bar results, sidebar, browser panels,
  tooltips, find bar, and link-status popup.
- `userContent.css` — new-tab/home pages, Settings, Add-ons, and Downloads.
- `terminal-palette.css` — shared colors and controls. Both entrypoints import
  it locally; its rules are also scoped to Firefox-owned documents.

Ordinary websites and certificate/network-error pages are not restyled.
Tab close buttons, audio/security indicators, container stripes, group labels,
window controls, drag regions, and toolbar buttons are not hidden or reordered.
Native macOS menu-bar menus and OS dialogs may retain their system appearance.

## Install

1. Open `about:support` in Firefox. Next to **Profile Folder**, click
   **Show in Finder** (macOS) or **Open Directory** (Linux). Use that active
   profile, not the Firefox application folder or another profile.
2. Open `about:config`, find
   `toolkit.legacyUserProfileCustomizations.stylesheets`, and set it to **true**.
3. Quit Firefox completely.
4. Create a `chrome` directory inside the profile folder if it doesn't exist.
5. Copy **all three CSS files** from
   `~/.dotfiles/home/dot_config/firefox/chrome/` into that directory.
6. Start Firefox again. Using the built-in **System theme — auto** is recommended.

If you already have `userChrome.css` or `userContent.css`, **back them up and
don't overwrite them**. Keep this theme's files in a separate subdirectory, for
example `chrome/terminal/`, and add these imports at the beginning of your
existing files, before any `@namespace` or style rules:

```css
/* At the beginning of chrome/userChrome.css: */
@import url("terminal/userChrome.css");

/* At the beginning of chrome/userContent.css: */
@import url("terminal/userContent.css");
```

Other themes can conflict with these rules; enable one theme at a time when
diagnosing issues. The same instructions work on macOS and Linux. Locate the
profile with `about:support` rather than hardcoding its randomized directory.

After `chezmoi apply`, the source files are also available at
`~/.config/firefox/chrome/`. This is a **staging directory**, not a Firefox
profile. Chezmoi does not automatically install them into profiles or change
Firefox preferences.

## Customize

Edit the top of `terminal-palette.css` in the installed copy:

```css
--terminal-appearance: light dark; /* system; use dark or light to force one */
--terminal-font: "Victor Mono", ui-monospace, monospace;
--terminal-size: 13px;
```

The same palette is used by the GitHub and Jira themes. Changes to these CSS
files require a **full Firefox restart**; Stylus live reload does not apply to
browser chrome. If installed by copying, copy updated files into the profile
again after editing the repo versions.

To keep the new-tab page especially plain, select no wallpaper and disable
unwanted recommended/sponsored content in Firefox's own new-tab settings. The
CSS doesn't change those preferences or hide the content for you.

## Undo / troubleshoot

- Set `toolkit.legacyUserProfileCustomizations.stylesheets` back to **false**
  and restart Firefox to disable all profile CSS.
- To disable just this theme, remove its import lines or move its CSS files out
  of `chrome/`, then restart. Restore any files you backed up.
- Firefox Troubleshoot Mode temporarily disables `userChrome.css` and
  `userContent.css`, allowing you to recover without deleting your profile.
- After Firefox upgrades, check selected tabs, address suggestions, menu items,
  tooltips, keyboard focus, and both horizontal/vertical tabs. UI CSS is not a
  stable extension API and selectors may need updates.

Token names and selectors were checked against the installed Firefox 158 UI
sources. Live browser rendering was not verified in the sandbox.
