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

_(none yet — filled in on first run)_

## Things to avoid

_(none yet)_

## Standard sign-off

_(fill in once observed — e.g. "Best, Albert" vs. "Thanks!" vs. nothing)_
