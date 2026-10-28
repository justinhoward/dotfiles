# Firefox / terminal

A matching Sonokai/Everforest and Victor Mono theme for Firefox's UI and built-in
pages, installed through profile CSS rather than Stylus.

Horizontal tabs use a flush, borderless 32px minimum row with a selected fill.
Window controls and drag spacers stay native; vertical tabs retain their sizing.

## Install

Run `chezmoi apply`, open the active **Profile Folder** from `about:support`, and
set `toolkit.legacyUserProfileCustomizations.stylesheets` to **true** in
`about:config`, then quit Firefox. If the profile has no custom CSS, create its
`chrome/` directory and copy all three files from `~/.config/firefox/chrome/` into
it. Otherwise, back up existing `userChrome.css` / `userContent.css` instead of
overwriting them: put this theme's files in `chrome/terminal/` and prepend
`@import url("terminal/userChrome.css");` and
`@import url("terminal/userContent.css");` to the corresponding existing files,
before any other rules or `@namespace`. Restart using **System theme — auto**;
customize `terminal-palette.css`, and copy updates into the profile and restart.
