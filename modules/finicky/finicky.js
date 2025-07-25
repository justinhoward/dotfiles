const browser = "Firefox"

export default {
  defaultBrowser: browser,
  options: {
    hideIcon: true
  },
  handlers: [
    // zoom.us/join links open in Zoom app
    {
      match: /zoom\.us\/(join|j)\//,
      browser: 'us.zoom.xos'
    },
    // Open links from Slack in the background
    {
      match: (_, { opener }) => opener.bundleId === 'com.tinyspeck.slackmacgap',
      browser: {
        name: browser,
        openInBackground: true
      }
    }
  ]
}
