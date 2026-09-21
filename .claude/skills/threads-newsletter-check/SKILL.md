---
name: threads-newsletter-check
description: Daily check of the user's Threads saved posts for new AI-news material. Accumulates relevant finds and, once there's enough for an interesting issue, drafts a newsletter in the user's learned voice. Never sends or publishes anything — always stops at a draft file. Run this once a day via a local scheduler (see newsletter/README.md); it can also be invoked manually.
---

# Threads → AI Newsletter: daily check

You are running the daily pass of a personal newsletter pipeline. The user
saves things on Threads (threads.net) that catch their eye as AI news —
that's the *only* signal you're mining. Everything you need is under
`newsletter/`: `config.json`, `state.json`, `voice.md`, `learnings.md`,
`pending/items.jsonl`, plus `drafts/` and `archive/` output dirs. Read
`config.json` and `state.json` first; every path/threshold below refers to
values in `config.json` unless stated otherwise.

## 0. Browser tool check

You need a real, authenticated browser session — the user is already
logged into Threads in it. **Primary path:** use your native
browser/computer-use tool (Playwright-backed or similar) — Claude Code's
own browser, not one attached to the user's everyday Chrome window.

**Fallback:** if the native browser tool isn't available, errors out, or
can't get past Threads' login/rendering (e.g. it needs a session the
native tool doesn't have), it's fine to fall back to the Chrome
DevTools/extension tool for this run and say so in your summary to the
user — this was explicitly approved as a fallback, not a silent
substitution. Prefer retrying the native tool on the next scheduled run
rather than treating the extension as the new default; if it keeps
needing the fallback for several days in a row, flag that to the user
instead of quietly settling on the extension long-term.

If neither is available, stop and tell the user directly: this skill
can't run until a browser tool is configured, and do not attempt to
scrape Threads via HTTP fetch — it's an authenticated, JS-heavy app and
that will not work and may look like credential probing.

## 1. Collect new saved posts

1. Open Threads and navigate to the **Saved** view (from the profile menu
   or the bookmark icon — click through the UI rather than guessing a
   URL, since Threads' routes change).
2. Scroll through saved posts from the top (most recently saved) down.
   For each post, note a stable identifier (its permalink URL is best).
3. Stop once you reach a post whose id is already in
   `state.seen_saved_post_ids`, or after a reasonable scroll depth (~60
   posts) if the account has never been checked before — don't try to
   ingest someone's entire all-time saved history on first run.
4. For every *new* post (id not in `seen_saved_post_ids`):
   - Read the post text, author, and permalink.
   - Judge relevance against `config.relevance_topic`. Be reasonably
     inclusive of adjacent topics (e.g. AI policy, notable AI company
     news, a widely-discussed AI research thread) but exclude posts that
     just happen to mention "AI" in passing with no real content.
   - If relevant: append one line to `pending_file` (JSONL) with fields
     `{id, url, author, text_excerpt, found_at, subtopic}`. Keep
     `text_excerpt` short (a sentence or two) — enough to write from
     later, not a full copy. `subtopic` is your own short label (e.g.
     "new model release", "AI policy", "agents", "research") used only
     for the diversity check below.
   - Add the id to `state.seen_saved_post_ids` regardless of relevance
     (so you never re-evaluate it).
5. Update `state.last_checked_at` to now. If `state.pending_since` is
   null and you just added the first pending item, set it to today.

Write `state.json` back after this step even if you end up not drafting
today — the dedupe cursor must persist either way.

## 2. Decide whether today is a newsletter day

Read all lines currently in `pending_file`. Compute the count and the
number of distinct `subtopic` values.

- If count ≥ `min_relevant_items_for_draft` **and** distinct subtopics ≥
  `min_distinct_subtopics_for_draft` → write a draft (step 3).
- Else if `pending_since` is more than `max_days_to_wait_before_lowering_bar`
  days ago **and** count ≥ `lowered_bar_min_items` → write a lighter draft
  anyway (step 3), and say so plainly in the draft's intro (e.g. "a
  shorter one this week") rather than padding it to look bigger than it
  is.
- Otherwise → stop here. Do not write a draft. It's fine, even expected,
  to skip days. Log nothing beyond the updated `state.json`.

Never fabricate items to hit the threshold, and never pull in something
irrelevant just to pad the count — an accurate "not enough yet" is always
better than a forced issue.

## 3. Bootstrap the voice profile (first draft only)

Open `voice.md`. If its "Learned traits" section is still empty:
navigate to the user's own Threads profile (their own posts, not saved
ones) via the UI, read through 15-20 recent posts, and write 5-10 concrete
stylistic traits into that section (sentence length and rhythm, how
opinionated vs. descriptive, humor, recurring phrases, how they open/close
a thought, formatting habits). This only needs to happen once — skip it on
every later run once the section is populated.

## 4. Write the draft

Read, in this order, and treat later files as overriding earlier ones on
conflict:
1. `voice.md` — general tone.
2. `learnings.md` — every accumulated rule, most specific/most recent wins.

Then write an actual newsletter issue from the pending items (not a link
dump): a short hook to open, items grouped sensibly by theme where that
makes sense, a point of view on each item rather than just a summary, and
a close. Target length is `draft_target_word_count` words. Use the
saved posts' `text_excerpt`/`url`/`author` as source material — attribute
or link naturally where the user's voice would.

Save it to `draft_output_dir/YYYY-MM-DD.md` with this frontmatter:

```markdown
---
status: draft
generated_at: <ISO timestamp>
source_item_ids: [<the pending item ids used>]
---

<the newsletter body>
```

Then:
- Move the used lines out of `pending_file` into
  `archive_dir/used-YYYY-MM-DD.jsonl` (so pending resets to whatever's
  left over — there may be leftover irrelevant... no, leftover *unused*
  relevant items if you drafted before consuming everything; only remove
  the ones actually used).
- Set `state.pending_since` to null if `pending_file` is now empty,
  otherwise leave it as-is.
- Set `state.last_draft_written_at` and `state.last_draft_file`.

## 5. Never auto-send — hand it to the user

This skill's job ends at a draft file. Do not post, publish, or send
anything anywhere. If you're running with access to notify the user
(e.g. `SendUserFile`, a push notification tool), surface the new draft
file so they see it without having to go looking. If not, it's enough
that the file exists in `drafts/` — the user (or the next
`newsletter-feedback` invocation) will find it there.

Tell the user, in one or two sentences, what happened this run: how many
new relevant items were found, whether a draft was written and why (or
why not, in terms of the threshold).
