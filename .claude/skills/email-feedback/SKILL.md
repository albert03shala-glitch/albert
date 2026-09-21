---
name: email-feedback
description: Turns the user's feedback on a drafted email reply into durable rules (so the same mistake isn't repeated), then revises the draft. Invoke this whenever the user comments on, edits, or reacts to a draft created by email-draft-check.
---

# Email feedback → self-learning

Mirrors `newsletter-feedback`, applied to email drafts. The user is
reacting to a specific draft reply (in Gmail Drafts, or by describing it
to you in chat).

## 1. Identify the draft and read it in full

Find the draft in question (ask if ambiguous which thread).

## 2. Extract durable rules

Split the feedback into one-off edits (fix this draft only, don't log)
vs. durable rules (generalize — tone, formality, how to handle a
recurring type of request, standard phrasing to use or avoid). Append
every durable rule to `email/learnings.md` in its documented format
(date, rule as an instruction to your future self, why). Fold pure tone
traits into `email/voice.md`'s "Learned traits"/"Things to avoid"
sections, replacing superseded entries there rather than growing them
without bound.

## 3. Revise the draft

Update the same Gmail draft in place with the one-off edits plus every
applicable rule from `learnings.md`/`voice.md`. Do not send it.

## 4. Confirm

Reply briefly with the one-off edits made and the durable rule(s)
logged (quote them so the user can correct the generalization if it's
wrong). Never send the draft yourself.
