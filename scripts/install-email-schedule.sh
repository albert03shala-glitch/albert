#!/usr/bin/env bash
# Installs a recurring cron entry that runs the email-draft-check skill
# locally via the Claude Code CLI. Run this ON YOUR OWN MACHINE — Gmail
# access comes from the connector on your claude.ai account, not from any
# credential stored in this repo.
#
# Usage: ./scripts/install-email-schedule.sh [interval in minutes, default 120]

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INTERVAL="${1:-120}"

CLAUDE_BIN="$(command -v claude || true)"
if [[ -z "$CLAUDE_BIN" ]]; then
  echo "Could not find 'claude' on PATH. Install Claude Code CLI first, or" >&2
  echo "edit this script to point CLAUDE_BIN at its full path." >&2
  exit 1
fi

CRON_LINE="*/$INTERVAL * * * * cd $REPO_DIR && $CLAUDE_BIN -p \"/email-draft-check\" >> $REPO_DIR/email/cron.log 2>&1"

echo "About to add this line to your crontab (runs every $INTERVAL minutes):"
echo "  $CRON_LINE"
read -r -p "Proceed? [y/N] " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Aborted, nothing changed."
  exit 0
fi

( crontab -l 2>/dev/null | grep -vF "email-draft-check" ; echo "$CRON_LINE" ) | crontab -

echo "Installed. Runs every $INTERVAL minutes."
echo "Make sure the Gmail connector is connected and enabled for whatever"
echo "Claude Code session/profile this cron job runs under."
echo
echo "To remove later: crontab -e  and delete the email-draft-check line."
