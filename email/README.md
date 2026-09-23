# Email draft agent

Reads your inbox (albert03shala@hotmail.com, via the **Microsoft 365**
connector) and writes reply **drafts** in your voice — never sends
anything. You review and hit send yourself, exactly like the Threads
newsletter pipeline works for newsletter issues.

## One-time setup

1. Go to claude.ai → Settings → Connectors and connect **Microsoft
   365**, signing in with albert03shala@hotmail.com, then make sure it's
   enabled for whatever chat/session you run this from.
2. Run `/email-draft-check` once manually to bootstrap `voice.md` from
   your Sent folder and check for messages needing a reply.

### Known limitation

The Microsoft 365 connector's Outlook tools are search/read-only as far
as we've seen (`outlook_email_search`, `outlook_calendar_search`, etc.)
— no tool to create or update an Outlook draft. If that holds true once
connected, `email-draft-check` falls back to writing suggested replies
as local files under `drafts/` instead of real Outlook drafts, and tells
you to copy them in yourself. If Microsoft later exposes a draft tool
(or you connect a different mail connector), the skill will use it
directly — check its report each run to see which mode it used.

## Ongoing use

- Run `/email-draft-check` whenever you want a pass (manually, or on a
  schedule — see `scripts/install-email-schedule.sh` for a local cron
  option, same pattern as the newsletter's daily job).
- When you edit or comment on a draft it created, that's
  `/email-feedback`'s job: it captures any general rule behind your
  feedback into `learnings.md`/`voice.md` and updates the draft.

## Files

| Path | Purpose |
|---|---|
| `config.json` | Scope (which mail counts) and settings. |
| `state.json` | Which messages have already been looked at. |
| `voice.md` | Current summary of how you write email. |
| `learnings.md` | Full append-only log of feedback-derived rules. |
| `drafts/` | Fallback location for suggested replies, only used if no real draft tool is available for the connected account. |

## Hard rule

This pipeline only ever creates or updates **drafts**. It must never send,
archive, delete, or otherwise act on your mailbox — that's by design, not
a setting to relax casually. If you decide later you want limited
auto-send for specific low-risk cases, that needs an explicit, narrow rule
added to `config.json` and to the skill itself — not a blanket switch.
