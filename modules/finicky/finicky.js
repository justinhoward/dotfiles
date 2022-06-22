const browser = "Firefox"

module.exports = {
  defaultBrowser: browser,
  options: {
    hideIcon: true
  },
  handlers: [
    //////// Zoom ////////////
    {
      // Zoom links from zoom open in default
      match: ({opener, url }) => opener.bundleid === "us.zoom.xos" && url.host.includes("zoom.us"),
      browser: browser
    },
    {
      // Zoom links open in zoom 
      match: [
        "zoom.us/*",
        finicky.matchDomains(/.*\zoom.us/),
        /zoom.us\/j\//,
      ],
      browser: "us.zoom.xos"
    },

    //////// Slack ////////////
    {
      match: ({ opener }) => opener.bundleId === 'com.tinyspeck.slackmacgap',
      browser: {
        name: browser,
        openInBackground: true
      }
    }
  ]
}
