#!/bin/bash
# claude-bell: Notify when Claude Code needs attention in Ghostty
# https://github.com/IvanWeiZ/claude-bell
#
# Ghostty focused:   🔔 tab indicator only
# Ghostty unfocused: 🔔 + dock bounce + macOS notification (click to open)

# Find the TTY by walking up the process tree
# Claude Code hooks run in a subprocess with no TTY attached,
# so we walk up until we find an ancestor with a real TTY device.
find_tty() {
  local pid=$$
  while [ "$pid" -gt 1 ]; do
    local tty=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
    if [ -n "$tty" ] && [ "$tty" != "??" ] && [ -e "/dev/$tty" ]; then
      echo "$tty"
      return
    fi
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
  done
}

TTY=$(find_tty)

# Always ring the bell for 🔔 tab indicator
[ -n "$TTY" ] && printf '\a' > "/dev/$TTY"

# Extra notifications only when Ghostty is NOT focused
FRONT=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
FRONT_LOWER=$(echo "$FRONT" | tr '[:upper:]' '[:lower:]')
[ "$FRONT_LOWER" = "ghostty" ] && exit 0

# Dock bounce (without stealing focus)
osascript -e 'tell application "Ghostty" to «event aevtnimp»' 2>/dev/null &

# macOS notification — click to open Ghostty
NOTIFIER="${TERMINAL_NOTIFIER:-/opt/homebrew/bin/terminal-notifier}"
if [ -x "$NOTIFIER" ]; then
  "$NOTIFIER" \
    -title "Claude Code" \
    -message "Claude needs your attention" \
    -activate "com.mitchellh.ghostty" \
    -ignoreDnD &
fi
