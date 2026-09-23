---
name: email-draft-check
description: Checks the user's inbox for messages needing a reply and writes draft replies (in their learned voice) — as a real mail-provider draft when the connected tool supports it, otherwise as a local suggested-reply file. Never sends anything. Run periodically via a local scheduler (see email/README.md), or invoke manually to check now.
---

# Email → draft replies

You are running a pass of the user's personal email-drafting pipeline.
Everything you need is under `email/`: `config.json`, `state.json`,
`voice.md`, `learnings.md`. Read `config.json` first — it names the
account and connector currently in use (as of writing:
albert03shala@hotmail.com via the Microsoft 365 connector) — and
`state.json`.

**This skill only ever produces drafts for review. It must never send,
archive, or delete anything, and it must never reply to anyone without
the user reviewing it first.** That's a hard rule, not a default — if
you're ever tempted to send directly because a reply seems obviously
safe, don't; produce the draft and let the user send it.

## 0. Tool check

You need mail tools for the account named in `config.json` — at least
something to search the inbox and read a full message/thread. If
nothing is available, tell the user directly that the connector needs
to be connected via claude.ai → Settings → Connectors and enabled for
this chat — do not attempt to read email any other way (no scraping, no
guessing at IMAP/SMTP credentials).

Then check specifically for a tool that creates or updates a draft on
the mail provider itself (e.g. something like `create_draft`,
`update_draft`, `create_or_update_draft`). **As of the Microsoft 365
connector's tool list at the time this skill was written, no such tool
exists** — its Outlook tools are search/read-only. If you don't find one:
- Use **fallback mode**: write suggested replies to markdown files under
  `config.fallback_draft_dir` instead of a real draft (format in step 3).
- Say so explicitly in your step-4 report — don't let the user assume
  these are sitting in their actual Drafts folder when they aren't.
If a draft-creation tool *is* available (Microsoft added one, or a
different connector is now connected), use **draft mode**: create/update
a real draft on the thread instead of a local file, and say so.

## 1. Find messages that need a reply

Per `config.scope`: look at the Primary inbox, unread threads only,
skipping Promotions/Social/Updates/Spam categories. Within what's left,
use judgment to skip messages that don't actually need a reply from the
user even though they're unread — automated notifications, no-reply
senders, receipts, newsletters, calendar invites that don't need a
written response. Skip anything whose message id is already in
`state.processed_message_ids`.

## 2. Bootstrap the voice profile (first run only)

If `voice.md`'s "Learned traits" section is still empty, read 15-20 of
the user's own Sent emails and fill it in per the instructions already
written at the top of that file. Do this once; skip on later runs.

## 3. Draft a reply for each message that needs one

Read `voice.md` then `learnings.md` (later file wins on conflict) for
tone and rules. Read the full thread for context, not just the latest
message. Write a reply that actually addresses what's being asked —
not a generic acknowledgment — in the user's voice.

- **Draft mode**: create/update it as a real draft on that thread
  (reply-draft, not a new email).
- **Fallback mode**: save it as
  `<fallback_draft_dir>/YYYY-MM-DD-<short-subject-slug>.md` with
  frontmatter `{status: suggested-reply, thread_id, subject, from, to}`
  and the reply body below it, ready to copy into a real reply.

Either way, add every message id you looked at (whether or not you
drafted a reply) to `state.processed_message_ids`, and set
`state.last_checked_at`.

If a message is ambiguous enough that you're genuinely unsure what the
user would want to say (not just "what's the best phrasing" — an actual
decision only they can make, e.g. agreeing to something, declining
something, committing to a date), still draft your best attempt but open
the draft with a short bracketed note to the user flagging the decision
point, e.g. `[This assumes you're free Thursday — check before sending]`.
Don't silently guess on things that commit the user to something.

## 4. Report back

Tell the user briefly: which mode you ran in (draft mode or fallback
mode, and why), how many threads you looked at, how many
drafts/suggested-reply files you created (and for whom/subject,
briefly), and how many you skipped and why. Never claim to have
"answered" anything — you produced replies for them to send.
