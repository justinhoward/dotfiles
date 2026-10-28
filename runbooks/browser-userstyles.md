# Browser / terminal userstyles

Victor Mono, square controls, and Sonokai dark / Everforest light themes for
Firefox + [Stylus][stylus].

- [GitHub][github]: Monospace files, issues, and diffs with distinct status colors.
- [Jira][jira]: Matching Jira Cloud boards and issues, preserving status categories.
- [Gmail][gmail]: Matching mail UI, with light canvases for email bodies and editors.
- [Calendar][calendar]: Matching Google Calendar, preserving event colors and layout.
- [YouTube Music][music]: Matching library, queue, and player; album art stays native.
- [Messages][messages]: Matching Google Messages for web, with distinct
  sent/received bubbles.

## Install

Install Stylus in Firefox (146+ for Gmail), run `chezmoi apply`, and open the
chosen `~/.config/stylus/*.user.css` file with **Cmd/Ctrl+O**; choose **Install
style**, disable conflicting userstyles, and refresh the site. If the installer
doesn't open, use **Stylus → Manage → Write new style → as UserCSS** and paste the
whole file. Use the style's gear icon to change appearance, font, or text size;
after updates, reopen the file, choose **Reinstall style**, and refresh again.
Gmail works best with its **Default** theme; Calendar with **Device default**.

YouTube Music and Messages use the same appearance options independently of
their app themes. These styles do not change playback, conversation layout,
attachments, or QR pairing images. Site updates can change private selectors;
check both light and dark appearance after reinstalling.

[stylus]: https://addons.mozilla.org/firefox/addon/styl-us/
[github]: ../home/dot_config/stylus/github-terminal.user.css
[jira]: ../home/dot_config/stylus/jira-terminal.user.css
[gmail]: ../home/dot_config/stylus/gmail-terminal.user.css
[calendar]: ../home/dot_config/stylus/calendar-terminal.user.css
[music]: ../home/dot_config/stylus/youtube-music-terminal.user.css
[messages]: ../home/dot_config/stylus/messages-terminal.user.css
