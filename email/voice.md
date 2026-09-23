# Email Voice Profile

How the user writes email replies, so drafts sound like them rather than
generic assistant copy. Filled in the same two ways as the newsletter's
voice profile:

1. **Bootstrap pass.** The first time `email-draft-check` runs and
   "Learned traits" is still empty, read a sample (15-20) of the user's
   own **Sent** emails and infer concrete traits: typical greeting/sign-off,
   formality level, sentence length, how direct vs. hedging they are,
   how they handle requests they want to decline, formatting habits
   (bullet points vs. prose, how long replies usually run).
2. **Feedback pass.** Every time the user edits or comments on a drafted
   reply via `email-feedback`, durable rules land here (detailed log in
   `learnings.md`).

## Learned traits

_(bootstrap attempted 2026-09-21 — inconclusive, see note below)_

## Things to avoid

_(none yet)_

## Standard sign-off

_(fill in once observed — e.g. "Best, Albert" vs. "Thanks!" vs. nothing)_

## Bootstrap note (2026-09-21, Gmail account)

Sent folder only has 2 messages total (Oct 2024 and Feb 2025), and both
are bare file-shares to friends with no written body text — nothing to
infer tone from. Skipped fabricating traits rather than guessing.

## Bootstrap note (2026-09-23, Hotmail account via Gmail POP import)

Switched target account to albert03shala@hotmail.com, imported into
Gmail via POP. POP only pulls the inbox, not Sent — there's no way to
read this account's own sent mail through this setup at all, so the
automatic bootstrap can't run here either. Two ways forward: paste a few
example replies you've written and I'll seed this file by hand, or leave
it empty and rely entirely on the feedback pass (slower to converge, but
still works — every correction still gets logged and applied).
