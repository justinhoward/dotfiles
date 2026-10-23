# Browser / terminal userstyles

Victor Mono, square controls, and Sonokai dark / Everforest light themes for
Firefox + [Stylus][stylus].

- [GitHub][github]: Monospace files, issues, and diffs with distinct status colors.
- [Jira][jira]: Matching Jira Cloud boards and issues, preserving status categories.
- [Gmail][gmail]: Matching mail UI, with light canvases for email bodies and editors.
- [Calendar][calendar]: Matching Google Calendar, preserving event colors and layout.

## Install

Install Stylus in Firefox (146+ for Gmail), run `chezmoi apply`, and open the
chosen `~/.config/stylus/*.user.css` file with **Cmd/Ctrl+O**; choose **Install
style**, disable conflicting userstyles, and refresh the site. If the installer
doesn't open, use **Stylus → Manage → Write new style → as UserCSS** and paste the
whole file. Use the style's gear icon to change appearance, font, or text size;
after updates, reopen the file, choose **Reinstall style**, and refresh again.
Gmail works best with its **Default** theme; Calendar with **Device default**.

[stylus]: https://addons.mozilla.org/firefox/addon/styl-us/
[github]: ../home/dot_config/stylus/github-terminal.user.css
[jira]: ../home/dot_config/stylus/jira-terminal.user.css
[gmail]: ../home/dot_config/stylus/gmail-terminal.user.css
[calendar]: ../home/dot_config/stylus/calendar-terminal.user.css
