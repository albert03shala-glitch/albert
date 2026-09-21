# Voice Profile

This describes how the user writes, so drafts sound like them instead of
generic AI-newsletter copy. It starts almost empty and fills in over time
in two ways — never by guessing once and freezing:

1. **Bootstrap pass.** The first time `threads-newsletter-check` writes a
   draft and the "Learned traits" section below is still empty, it should
   open the user's own Threads profile (not saved posts — their own posts)
   and read through their recent posts to infer concrete stylistic traits:
   typical sentence length, how opinionated vs. purely descriptive they
   are, humor, favorite phrases or verbal tics, how they open and close a
   thought, formatting habits (em dashes, lists, one-liners vs. paragraphs).
   Write 5-10 concrete traits here, each with a short example.

2. **Feedback pass.** Every time the user reacts to a draft through the
   `newsletter-feedback` skill, any durable tone rule that comes out of it
   gets added under "Learned traits" or "Things to avoid" below (the
   detailed log of every piece of feedback lives in `learnings.md` — this
   file should only hold the settled, current rules, kept short enough to
   actually be re-read before every draft).

## Learned traits

_(none yet — filled in on first run via the bootstrap pass above)_

## Things to avoid

_(none yet)_

## Sample lines the user likes

_(add short example sentences pulled from approved drafts here as they
accumulate, so future drafts have concrete style to imitate, not just
abstract rules)_
