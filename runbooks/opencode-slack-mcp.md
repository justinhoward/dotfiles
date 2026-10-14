# Community Slack MCP for OpenCode

Uses [korotovsky/slack-mcp-server](https://github.com/korotovsky/slack-mcp-server),
installed with **Homebrew**. The launcher at `~/.config/opencode/slack-mcp.sh`
runs `slack-mcp-server` from the OpenCode service's `PATH` over stdio;
no Node/npm, listening port, hosted intermediary, or new Slack app is needed for
browser-session authentication. Homebrew manages the installed version; the
current formula is **1.3.0**, matching the catalog below. The explicit tool
allowlist and default-deny policy remain in place after upgrades.

## Tool policy

The selected policy is **reads + messaging**: 13 tools are registered and every
one requires OpenCode approval. The remaining nine tools are excluded by the
server allowlist and denied by OpenCode's `slack_*` fallback. New tool names are
denied too. The `explore` and `scout` agents cannot use Slack tools.

This catalog is verified against the v1.3.0
[server source](https://github.com/korotovsky/slack-mcp-server/blob/v1.3.0/pkg/server/server.go),
not just the README (which omits some tools).

| Tool | Current policy | Purpose |
| --- | --- | --- |
| `conversations_history` | Ask | Read channel/DM messages |
| `conversations_replies` | Ask | Read a thread |
| `conversations_search_messages` | Ask | Search messages |
| `conversations_unreads` | Ask | Fetch unread messages |
| `channels_list` | Ask | List workspace channels |
| `channels_me` | Ask | List channels you belong to |
| `users_search` | Ask | Find users |
| `usergroups_list` | Ask | List mention groups and optionally members |
| `attachment_get_data` | Ask | Fetch attachment contents, up to 5 MB |
| `saved_list` | Ask | Read your Save for Later items |
| `conversations_add_message` | Ask | Send a message or thread reply |
| `reactions_add` | Ask | Add a reaction |
| `reactions_remove` | Ask | Remove a reaction |
| `conversations_mark` | Deny / not registered | Mark a conversation as read |
| `conversations_join` | Deny / not registered | Join a public channel |
| `conversations_leave` | Deny / not registered | Leave a channel, group conversation, or DM |
| `usergroups_me` | Deny / not registered | List your groups, join, or leave (mixed read/write) |
| `usergroups_create` | Deny / not registered | Create a mention group |
| `usergroups_update` | Deny / not registered | Change group metadata |
| `usergroups_users_update` | Deny / not registered | Replace the entire group membership list |
| `saved_update` | Deny / not registered | Mark a saved item complete or change its due date |
| `saved_clear_completed` | Deny / not registered | Bulk-clear completed saved items |

OpenCode permission names add the server prefix, e.g.
`slack_conversations_add_message`. To permanently exclude another tool, remove
its name from `SLACK_MCP_ENABLED_TOOLS` and remove its explicit `ask` permission
from `home/dot_config/opencode/opencode.jsonc.tmpl`. The fallback denies it.
Reapply and reconnect the server afterward.

Approvals are per tool, not per argument: `usergroups_me` cannot be made
list-only with an ordinary MCP permission rule. Choose **Allow once** to retain
per-call approval; **Allow always** saves a project-level approval. Configured
denials still take precedence over saved approvals.

### Separate resources and background work

The server also exposes `slack://<workspace>/channels` and
`slack://<workspace>/users` resources independently of its tool allowlist.
It authenticates and warms channel/user caches on startup without a tool call.
Tool approval does not gate this server-internal work or constitute an OS
sandbox around the MCP process. Channel/user metadata is cached locally.

## Browser-session credentials (macOS)

Use your own authorized Slack session, consistent with your workspace policy.
Do not paste tokens into chat, repo files, shell history, or OpenCode config.

1. Sign in to Slack in your browser. Follow the upstream
   [browser authentication instructions](https://github.com/korotovsky/slack-mcp-server/blob/v1.3.0/docs/01-authentication-setup.md#option-1-using-slack_mcp_xoxc_tokenslack_mcp_xoxd_token-browser-session)
   to obtain your workspace's **`xoxc-...` token** and the **`d` cookie**, whose
   value begins with **`xoxd-...`**. Treat both as account credentials.
2. Open **Keychain Access**, choose the **login** keychain, and create two
   **password items** (File → New Password Item):

   | Keychain Item Name | Account Name | Password |
   | --- | --- | --- |
   | `opencode-slack-mcp-xoxc` | Your macOS short username (`id -un`) | The complete xoxc token |
   | `opencode-slack-mcp-xoxd` | The same username | The complete d-cookie value |

3. If Keychain requests authorization on startup, review the request and allow
   the intended lookup. A locked keychain or denied lookup prevents connection.

The launcher retrieves these entries and exports them **only inside the MCP
process tree**, not OpenCode's general environment. Do not also export the
tokens from your shell profile. Stale user/bot token variables are cleared in
the launcher to prevent credential precedence surprises.

OpenCode and Fence deny ordinary agent-shell generic-password lookups and
Keychain dumps. This is an accident-prevention boundary, not protection against
a malicious local program running as your user. The MCP implementation and its
dependencies must still be trusted; tool responses contain Slack data sent to
the model. Logs are set to `warn` to avoid routine tool-argument logging.

Browser credentials can expire or be revoked. If authentication stops working,
update the two Keychain password items and reconnect. This launcher currently
supports macOS only.

## Apply and connect

Run in your own terminal; the agent cannot apply files into `~/.config`:

```sh
brew install slack-mcp-server
chezmoi diff ~/.config/opencode/opencode.jsonc ~/.config/opencode/slack-mcp.sh ~/.config/fence/fence.jsonc
chezmoi apply ~/.config/opencode/opencode.jsonc ~/.config/opencode/slack-mcp.sh ~/.config/fence/fence.jsonc
opencode service restart
opencode mcp list
```

Slack has a five-minute startup timeout because the server waits for channel/user
caches before accepting stdio requests. If the first launch still times out,
run `SLACK_MCP_LOG_LEVEL=info ~/.config/opencode/slack-mcp.sh` in your terminal
and let it reach **Starting STDIO server** to populate the caches; then press
Ctrl+C and reconnect via `/mcps`. There is no automatic package download in
the launcher.
There is no separate MCP OAuth sign-in for this browser-token setup.

Installation is active only once `opencode mcp list` reports **slack connected**.
This replaces the earlier official-Slack config; `SLACK_MCP_CLIENT_ID` and the
official OAuth callback are no longer used.

## References

- [Homebrew formula](https://formulae.brew.sh/formula/slack-mcp-server)
- [Pinned source/tool registration](https://github.com/korotovsky/slack-mcp-server/blob/v1.3.0/pkg/server/server.go)
- [Upstream authentication](https://github.com/korotovsky/slack-mcp-server/blob/v1.3.0/docs/01-authentication-setup.md)
- [Upstream configuration](https://github.com/korotovsky/slack-mcp-server/blob/v1.3.0/docs/03-configuration-and-usage.md)
- [OpenCode V2 MCP](https://opencode.ai/v2/docs/mcp-servers)
- [OpenCode V2 permissions](https://opencode.ai/v2/docs/permissions)
