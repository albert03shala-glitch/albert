---
name: newsletter-feedback
description: Turns the user's feedback on a newsletter draft into durable rules (so the same mistake isn't repeated), then revises that draft. Invoke this whenever the user comments on a draft in newsletter/drafts/ — critiques, edits, "don't do X next time", or approval.
---

# Newsletter feedback → self-learning

The user is reacting to a specific draft in `newsletter/drafts/`. Your job
is twofold: capture what's reusable from their feedback so future drafts
don't repeat the mistake, and revise the current draft to match.

## 1. Identify the draft

Figure out which file in `newsletter/drafts/` the feedback is about (most
recently modified one if it's ambiguous, or ask if genuinely unclear).
Read it in full before doing anything else.

## 2. Extract durable rules from the feedback

Read the user's feedback carefully and separate it into two kinds of
things:

- **One-off edits**: "cut this paragraph", "this link is wrong", "swap
  the order of these two items" — these only affect this draft. Apply
  them directly, don't log them.
- **Durable rules**: anything that generalizes — a tone preference
  ("too many em dashes", "stop opening with a question", "I never say
  'game-changer'"), a structural preference ("keep intros under two
  sentences", "always end with one concrete takeaway, not a summary"), a
  content-selection preference ("skip funding-round news unless it's a
  huge number", "I care more about open-source model releases than
  closed ones"). If you're not sure whether something is one-off or
  durable, lean toward durable but phrase the rule narrowly enough that
  it's actually true in general, not just a rephrasing of this one
  complaint.

For every durable rule, append an entry to `newsletter/learnings.md`
following the format already documented at the top of that file (date,
rule, why). Write the rule as an instruction to your future self, not a
description of what went wrong — e.g. "Rule: never use the phrase
'game-changer' or similar hype words" rather than "Rule: draft used hype
language." If a rule refines or contradicts an earlier entry, add the new
one and note in it which older entry it supersedes — don't edit history
out.

If any rule is really about overall tone rather than a specific mistake
(e.g. "I'm more sarcastic than that", "shorter sentences throughout"),
also fold it into the "Learned traits" or "Things to avoid" sections of
`newsletter/voice.md`, keeping those sections short and current rather
than letting them grow without bound — if a new trait supersedes an old
one, replace it there (the full history still lives in `learnings.md`).

## 3. Revise the draft

Apply both the one-off edits and the newly-logged durable rules (plus
everything already in `learnings.md` and `voice.md`) to produce a revised
version. Overwrite the same draft file in place, bump a `revision` counter
in its frontmatter (start at 2 if the field didn't exist), and keep
`source_item_ids` unchanged.

If the feedback is a flat rejection ("this isn't good, start over" / "none
of this is interesting") rather than specific notes: still log whatever
general rule you can extract (even just "Why: user rejected the whole
draft as uninteresting" with your best guess at a rule), then ask the user
one clarifying question about what direction to take instead before
rewriting from scratch — don't guess twice at their expense. If they
explicitly say the *material* was the problem, not the writing, move the
draft's source items from `newsletter/archive/` back into
`newsletter/pending/items.jsonl` and tell them so, since that data feeds
the next scheduled run's threshold check.

## 4. Confirm

Reply briefly: what one-off edits you made, what durable rule(s) you
logged (quote them — the user should be able to correct you if you
generalized wrong), and that the draft file has been updated in place.
Never send, post, or publish the draft yourself at any point in this
flow — it stays a local file for the user to act on.
