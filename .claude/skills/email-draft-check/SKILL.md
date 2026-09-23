---
name: email-draft-check
description: Checks the user's inbox for messages needing a reply and writes draft replies (in their learned voice) — as a real mail-provider draft when the connected tool supports it, otherwise as a local suggested-reply file. Never sends anything. Run periodically via a local scheduler (see email/README.md), or invoke manually to check now.
---

# Email → draft replies

You are running a pass of the user's personal email-drafting pipeline.
Everything you need is under `email/`: `config.json`, `state.json`,
`voice.md`, `learnings.md`. Read `config.json` first — it names the
account and connector currently configured (`account`, `connector`
fields; this has changed more than once, so trust the file over
anything you remember) — and `state.json`.

**This skill only ever produces drafts for review. It must never send,
archive, or delete anything, and it must never reply to anyone without
the user's explicit permission.** That's a hard rule, not a default —
if you're ever tempted to send directly because a reply seems obviously
safe, don't; produce the draft and let the user send it.

Concretely: never call a tool that sends mail directly, such as
`reply`, `send_message`, `forward`, or anything else that dispatches a
message rather than saving it — regardless of connector, and even if
the tool's own description makes it sound like the safer or more
convenient option (e.g. Gmail's `reply` tool sends immediately despite
the name — it is not a draft tool). Only ever use draft-creation tools
(`create_draft`, `update_draft`, or equivalent) or the local fallback
file. If no draft-creation tool exists and no fallback is configured,
stop and tell the user — do not fall back to sending as a last resort.

## 0. Tool check

You need mail tools for the account named in `config.json` — at least
something to search the inbox and read a full message/thread. If
nothing is available, tell the user directly that the connector needs
to be connected via claude.ai → Settings → Connectors and enabled for
this chat — do not attempt to read email any other way (no scraping, no
guessing at IMAP/SMTP credentials).

Then check specifically for a tool that creates or updates a draft on
the mail provider itself (e.g. something like `create_draft`,
`update_draft`, `create_or_update_draft`). Don't assume based on which
connector was configured last time — check the actual tool list loaded
right now, since the connector has changed more than once already.
- Found one → **draft mode**: create/update a real draft on the thread.
- Not found → **fallback mode**: write suggested replies to markdown
  files under `config.fallback_draft_dir` instead (format in step 3),
  and say so explicitly in your step-4 report — don't let the user
  assume these are sitting in their actual Drafts folder when they
  aren't.

## 1. Find messages that need a reply

Read `config.scope` and `config.note_on_setup` carefully — as of the
current setup, the target mail (albert03shala@hotmail.com) is imported
into the connected Gmail account via POP, sitting alongside the user's
native Gmail mail in the same inbox. **Scope your search to the
imported Hotmail mail specifically** (e.g. `deliveredto:` the Hotmail
address, or whatever label Gmail assigned the imported account — check
`list_labels` if unsure) — do not process the user's native Gmail mail
under this config unless `config.account`/`scope` says otherwise.

Within the unread messages that match, skip Promotions/Social/Updates
categories and use judgment to skip messages that don't actually need a
reply even though they're unread — automated notifications, no-reply
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
  (reply-draft, not a new email). Note the tool likely can't set a
  "Send mail as" alias, so the draft may default to the user's primary
  Gmail address rather than their Hotmail one — mention this in your
  report so they know to check the From field before sending.
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
