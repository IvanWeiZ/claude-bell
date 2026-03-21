# claude-bell 🔔

Never miss when Claude Code needs your attention. Get notified with a tab indicator, dock bounce, and macOS notification — all context-aware.

![macOS](https://img.shields.io/badge/macOS-000?logo=apple&logoColor=white)
![Ghostty](https://img.shields.io/badge/Ghostty-1.2%2B-blue)
![Claude Code](https://img.shields.io/badge/Claude%20Code-hooks-blueviolet)

## What it does

| Ghostty State | 🔔 Tab Indicator | Dock Bounce | macOS Notification |
|---|:---:|:---:|:---:|
| **Focused** | ✅ | — | — |
| **Unfocused** | ✅ | ✅ | ✅ (click to open) |

Triggers on all "waiting for you" events:
- **Stop** — Claude finished responding
- **Notification** — Claude sent a notification
- **Elicitation** — Claude is asking a question
- **PermissionRequest** — Claude needs tool approval

## Demo

```
┌─────────────────────────────────────────────────┐
│  🔔 claude ~/project   │   zsh   │   vim       │
├─────────────────────────────────────────────────┤
│                                                 │
│  $ claude                                       │
│                                                 │
│  Claude finished. Waiting for input...          │
│                                                 │
│  ┌──────────────────────────────┐               │
│  │ 🔔 Claude Code              │  ← macOS      │
│  │ Claude needs your attention  │    notification│
│  └──────────────────────────────┘               │
└─────────────────────────────────────────────────┘
```

## Setup (2 minutes)

### 1. Install terminal-notifier

```bash
brew install terminal-notifier
```

> After installing, enable notifications in **System Settings → Notifications → terminal-notifier**.

### 2. Install the hook script

```bash
mkdir -p ~/.claude/hooks
curl -o ~/.claude/hooks/notify-bell.sh \
  https://raw.githubusercontent.com/IvanWeiZ/claude-bell/master/notify-bell.sh
chmod +x ~/.claude/hooks/notify-bell.sh
```

### 3. Configure Claude Code hooks

Add to `~/.claude/settings.json` (merge with your existing config):

```json
{
  "hooks": {
    "Stop": [
      { "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/notify-bell.sh" }] }
    ],
    "Notification": [
      { "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/notify-bell.sh" }] }
    ],
    "Elicitation": [
      { "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/notify-bell.sh" }] }
    ],
    "PermissionRequest": [
      { "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/notify-bell.sh" }] }
    ]
  }
}
```

### 4. Configure Ghostty

Add to your Ghostty config (`~/.config/ghostty/config`):

```
bell-features = no-system,no-audio,no-attention,title,border
```

This enables the 🔔 tab indicator and border highlight on bell, without sound or dock bounce (the script handles dock bounce conditionally).

Reload config with `Cmd+Shift+,` or restart Ghostty.

## How it works

### The TTY problem

Claude Code hooks run in a subprocess where stdout is piped back to Claude — not to your terminal. So `printf '\a'` does nothing. The script solves this by walking up the process tree to find the ancestor with a real TTY:

```
hook script (PID=75209, tty=??)
  → parent (PID=75207, tty=??)
    → claude (PID=70541, tty=ttys001) ✅
```

Then writes the bell character directly to `/dev/ttys001`.

### Context-aware notifications

The script checks the frontmost app via AppleScript. If Ghostty is focused, you're already looking at it — so only the subtle 🔔 tab indicator fires. When you're in another app, it adds a dock bounce and a clickable macOS notification that brings you back to Ghostty.

## Customization

**Custom notification message:**
Edit the `-message` flag in `notify-bell.sh`.

**Disable dock bounce:**
Remove the `osascript -e 'tell application "Ghostty"...'` line.

**Disable macOS notification:**
Remove the `terminal-notifier` block.

**Custom terminal-notifier path:**
Set `TERMINAL_NOTIFIER=/path/to/terminal-notifier` in your environment.

## Requirements

- macOS (uses AppleScript and `osascript`)
- [Ghostty](https://ghostty.org) 1.2+
- [Claude Code](https://claude.ai/code) with hooks support
- [terminal-notifier](https://github.com/julienXX/terminal-notifier) (`brew install terminal-notifier`)

## License

MIT
