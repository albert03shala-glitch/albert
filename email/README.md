# Email draft agent

Reads your Hotmail mail (albert03shala@hotmail.com) — imported into the
already-connected **Gmail** account for free, rather than paying for a
dedicated Outlook connector — and writes reply **drafts** in your voice.
Never sends anything; you review and hit send yourself, exactly like the
Threads newsletter pipeline works for newsletter issues.

Two paid/blocked options were tried and ruled out first: Microsoft 365
rejects personal Hotmail/Outlook.com accounts (work/school only), and
Superhuman Mail works but costs ~400kr — not worth it just for this.

## One-time setup

1. In Gmail (the account already connected as a Claude connector): go to
   **Settings → Accounts and Import**.
   - Under "Check mail from other accounts", add
     albert03shala@hotmail.com so Gmail polls it via POP.
   - Under "Send mail as", also add albert03shala@hotmail.com and verify
     it, so you *can* send replies that look like they're from Hotmail —
     see the caveat below on whether drafts can pick that automatically.
2. Make sure the Gmail connector is enabled for whatever chat/session
   you run this from.
3. Run `/email-draft-check` once manually to bootstrap `voice.md` from
   your Sent folder and check for messages needing a reply.

### Caveat: which address a draft sends from

The Gmail draft-creation tool doesn't expose a way to pick a "Send mail
as" alias — a draft it creates will default to your primary Gmail
address unless Gmail's compose UI lets you switch the "From" field
before sending. Check that dropdown before hitting send if you want the
reply to go out as your Hotmail address, since the skill can't set that
for you.

### Fallback, just in case

If drafting in Gmail doesn't work as expected for the imported mail,
`email-draft-check` falls back to writing suggested replies as local
files under `drafts/` instead of a real mailbox draft, and says so
plainly in its report — check that report each run to see which mode it
used.

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
