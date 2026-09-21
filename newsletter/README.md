# Threads → AI Newsletter agent

A local pipeline that watches your Threads **saved posts**, notices when
you've saved enough interesting AI news to make a good issue, and drafts a
newsletter in your voice — never sending anything automatically.

## How it works

1. **`threads-newsletter-check`** (a Claude Code skill) runs once a day on
   your own machine. It opens Threads in Claude Code's own native browser
   tool by default (a separate, Claude-controlled browser, so it reuses
   whatever session you're logged into there), reads your Saved list, and
   keeps anything relevant to recent AI developments in
   `pending/items.jsonl`. If the native browser tool doesn't work, it's
   allowed to fall back to the Chrome extension for that run — it'll say
   so when it does.
2. Once there's enough pending material — by default at least 6 relevant
   items spanning at least 2 distinct subtopics — it writes a draft to
   `drafts/YYYY-MM-DD.md` and stops. If there isn't enough yet, it does
   nothing and waits; skipping days is expected and fine. After 5 days of
   waiting it will write a lighter issue anyway rather than stall forever
   (both numbers are configurable in `config.json`).
3. You read the draft and react to it in a normal chat with Claude Code —
   e.g. "the intro is too listy, and skip funding-round news unless it's
   huge." That triggers **`newsletter-feedback`**, which (a) revises the
   draft in place and (b) logs any *general* rule behind your feedback to
   `learnings.md` (and `voice.md` for pure tone notes), so every future
   draft is checked against everything you've ever said, not just today's
   note. Over a few rounds the drafts should converge to something you'd
   actually send with no edits.
4. Nothing here ever posts, publishes, or emails anything. The pipeline's
   output is always a markdown file in `drafts/` for you to take
   wherever you actually send your newsletter from.

## Files

| Path | Purpose |
|---|---|
| `config.json` | Thresholds and paths — edit freely. |
| `state.json` | Dedup cursor + run history. Don't hand-edit unless resetting. |
| `voice.md` | Current, short summary of how you write. Bootstrapped from your own Threads posts on first run, refined by feedback. |
| `learnings.md` | Full append-only log of every durable rule learned from feedback. |
| `pending/items.jsonl` | Relevant saved posts collected but not yet used in a draft. |
| `drafts/` | Generated newsletter drafts, newest by filename date. |
| `archive/` | Pending items that were consumed into a draft, kept for traceability. |

## One-time setup

1. Make sure Claude Code's native browser tool is available locally (not
   the Chrome DevTools extension) — check `claude doctor` or your MCP
   config if unsure.
2. Log into Threads once in that browser, as you normally would.
3. Run `./scripts/install-schedule.sh` from the repo root to add a daily
   cron entry (default 08:30 local time; pass a different `HH:MM` as an
   argument). If your setup needs the job to run even when you're not
   logged into your machine's desktop session, use launchd (macOS) or
   Task Scheduler (Windows) instead — point either at
   `claude -p "/threads-newsletter-check"` run from this repo's directory.
4. That's it — the first run will also bootstrap `voice.md` from your own
   Threads posts.

## Giving feedback on a draft

Just talk to Claude Code about the draft in `drafts/`, in this repo — "the
draft dated 2026-09-21 is too dry, and I never say 'landscape'" is enough
to trigger `newsletter-feedback` and have it logged and applied.

## Adjusting the bar for "enough material"

Edit `config.json`:
- `min_relevant_items_for_draft` / `min_distinct_subtopics_for_draft` —
  the normal threshold.
- `max_days_to_wait_before_lowering_bar` / `lowered_bar_min_items` — the
  fallback so you're not waiting forever if saves are slow one week.
- `relevance_topic` — the plain-English description used to judge what
  counts as "AI news" worth keeping; tighten or loosen it any time.
