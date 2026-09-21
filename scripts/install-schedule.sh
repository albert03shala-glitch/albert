#!/usr/bin/env bash
# Installs a daily cron entry that runs the threads-newsletter-check skill
# locally via the Claude Code CLI. Run this ON YOUR OWN MACHINE (not in a
# cloud/CI environment) — it needs your local, already-logged-in browser.
#
# Usage: ./scripts/install-schedule.sh [HH:MM in 24h local time, default 08:30]

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TIME="${1:-08:30}"
HOUR="${TIME%%:*}"
MIN="${TIME##*:}"

CLAUDE_BIN="$(command -v claude || true)"
if [[ -z "$CLAUDE_BIN" ]]; then
  echo "Could not find 'claude' on PATH. Install Claude Code CLI first, or" >&2
  echo "edit this script to point CLAUDE_BIN at its full path." >&2
  exit 1
fi

CRON_LINE="$MIN $HOUR * * * cd $REPO_DIR && $CLAUDE_BIN -p \"/threads-newsletter-check\" >> $REPO_DIR/newsletter/cron.log 2>&1"

echo "About to add this line to your crontab:"
echo "  $CRON_LINE"
read -r -p "Proceed? [y/N] " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Aborted, nothing changed."
  exit 0
fi

( crontab -l 2>/dev/null | grep -vF "threads-newsletter-check" ; echo "$CRON_LINE" ) | crontab -

echo "Installed. It will run once a day at $TIME local time."
echo "Note: your machine must be on and the terminal session Claude Code"
echo "needs (e.g. a logged-in browser profile) must be reachable at that"
echo "time — cron jobs run without an interactive terminal, so if your"
echo "browser tool requires one, consider launchd (macOS) or Task"
echo "Scheduler (Windows) with 'run whether user is logged in or not'"
echo "instead. See newsletter/README.md for details."
echo
echo "To remove later: crontab -e  and delete the threads-newsletter-check line."
