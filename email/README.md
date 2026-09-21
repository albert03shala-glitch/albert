# Email draft agent

Reads your Gmail inbox and writes reply **drafts** in your voice —
never sends anything. You review and hit send yourself, exactly like the
Threads newsletter pipeline works for newsletter issues.

## One-time setup

1. Go to claude.ai → Settings → Connectors and connect **Gmail**, then
   make sure it's enabled for whatever chat/session you run this from.
2. Run `/email-draft-check` once manually to bootstrap `voice.md` from
   your Sent folder and create your first batch of drafts.

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

## Hard rule

This pipeline only ever creates or updates **drafts**. It must never send,
archive, delete, or otherwise act on your mailbox — that's by design, not
a setting to relax casually. If you decide later you want limited
auto-send for specific low-risk cases, that needs an explicit, narrow rule
added to `config.json` and to the skill itself — not a blanket switch.
