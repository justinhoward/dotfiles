#!/bin/sh
# Local MCP launcher, executed by OpenCode outside Fence. Never print tokens.
# Store credentials in macOS Keychain, not OpenCode's inherited environment.
set -eu

if [ "$(uname -s)" != Darwin ]; then
    printf '%s\n' 'Slack MCP: this launcher requires macOS Keychain.' >&2
    exit 1
fi

# Do not let stale OAuth/bot credentials take precedence over this session.
unset SLACK_MCP_XOXP_TOKEN SLACK_MCP_XOXB_TOKEN SLACK_MCP_XOXC_TOKEN SLACK_MCP_XOXD_TOKEN

account=$(id -un)
if ! SLACK_MCP_XOXC_TOKEN=$(/usr/bin/security find-generic-password \
    -a "$account" -s opencode-slack-mcp-xoxc -w 2>/dev/null); then
    printf '%s\n' 'Slack MCP: cannot read Keychain item opencode-slack-mcp-xoxc; see the setup runbook.' >&2
    exit 1
fi
if ! SLACK_MCP_XOXD_TOKEN=$(/usr/bin/security find-generic-password \
    -a "$account" -s opencode-slack-mcp-xoxd -w 2>/dev/null); then
    printf '%s\n' 'Slack MCP: cannot read Keychain item opencode-slack-mcp-xoxd; see the setup runbook.' >&2
    exit 1
fi

case "$SLACK_MCP_XOXC_TOKEN" in
    xoxc-?*) ;;
    *) printf '%s\n' 'Slack MCP: the xoxc Keychain item has an invalid token prefix.' >&2; exit 1 ;;
esac
case "$SLACK_MCP_XOXD_TOKEN" in
    xoxd-?*) ;;
    *) printf '%s\n' 'Slack MCP: the xoxd Keychain item has an invalid token prefix.' >&2; exit 1 ;;
esac

export SLACK_MCP_XOXC_TOKEN SLACK_MCP_XOXD_TOKEN
exec slack-mcp-server --transport stdio
