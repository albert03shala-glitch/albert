---
name: email-draft-check
description: Checks the user's Gmail inbox for messages needing a reply and writes draft replies (in their learned voice) directly into Gmail's Drafts — never sends anything. Run periodically via a local scheduler (see email/README.md), or invoke manually to check now.
---

# Email → draft replies

You are running a pass of the user's personal email-drafting pipeline.
Everything you need is under `email/`: `config.json`, `state.json`,
`voice.md`, `learnings.md`. Read `config.json` and `state.json` first.

**This skill only ever creates drafts. It must never send, archive, or
delete anything, and it must never reply to anyone without the user
reviewing it first.** That's a hard rule, not a default — if you're ever
tempted to send directly because a reply seems obviously safe, don't;
create the draft and let the user hit send.

## 0. Tool check

You need mail tools loaded (search inbox, read a thread, create/update a
draft) for the user's account, albert03shala@hotmail.com — currently via
the **Superhuman Mail** connector (chosen because it supports personal
Outlook/Hotmail accounts and has a draft create/update tool; the
Microsoft 365 connector was ruled out — it's aimed at work tenants and
its Outlook tool is search-only). If no mail tools are available, tell
the user directly that the connector needs to be connected via claude.ai
→ Settings → Connectors and enabled for this chat — do not attempt to
read email any other way (no scraping, no guessing at IMAP/SMTP
credentials).

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
not a generic acknowledgment — in the user's voice, then create/update
it as a draft on that thread (reply-draft, not a new email). Add every
message id you looked at (whether or not you drafted a reply) to
`state.processed_message_ids`, and set `state.last_checked_at`.

If a message is ambiguous enough that you're genuinely unsure what the
user would want to say (not just "what's the best phrasing" — an actual
decision only they can make, e.g. agreeing to something, declining
something, committing to a date), still draft your best attempt but open
the draft with a short bracketed note to the user flagging the decision
point, e.g. `[This assumes you're free Thursday — check before sending]`.
Don't silently guess on things that commit the user to something.

## 4. Report back

Tell the user briefly: how many threads you looked at, how many drafts
you created (and for whom/subject, briefly), and how many you skipped
and why. Never claim to have "answered" anything — you drafted replies
for them to send.
