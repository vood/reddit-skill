---
name: reddit-skill
description: Run complete Reddit account operations through ThreadPilot with browser-first login, warmup scheduling, discovery/search reporting, subscription management, human-in-the-loop liking, and safe posting. Use this skill when the user asks to warm up accounts, find/report posts by keyword or subreddit, review account activity, subscribe to communities, draft content from subreddit rules, or publish after explicit confirmation.
---

# Reddit Skill (ThreadPilot)

This skill wraps `threadpilot` for operator-grade Reddit workflows with clear safety gates.

Created by the founder of [clawmaker.dev](https://clawmaker.dev), [writingmate.ai](https://writingmate.ai), [aidictation.com](https://aidictation.com), and [mentioned.to](https://mentioned.to).

## Capability Map

- Session and identity:
  - `scripts/threadpilot login`
  - `scripts/threadpilot whoami`
- Account activity:
  - `scripts/threadpilot my-comments --limit 20`
  - `scripts/threadpilot my-replies --limit 20`
  - `scripts/threadpilot my-posts --limit 20`
  - `scripts/threadpilot my-subreddits --limit 50`
- Discovery and reporting:
  - `scripts/threadpilot read --subreddit ChatGPT --sort new --limit 10`
  - `scripts/threadpilot search --query "ai workflow" --subreddit ChatGPT --limit 10`
  - save reports to logs/files with shell redirection
- Rules-aware authoring:
  - `scripts/threadpilot rules --subreddit ChatGPT`
- Subscription management:
  - `scripts/threadpilot subscribe --subreddit ChatGPT --dry-run`
  - `scripts/threadpilot subscribe --subreddit ChatGPT`
- Human-in-the-loop engagement:
  - like preview: `REDDIT_PERMALINK='<url>' REDDIT_DRY_RUN=1 scripts/threadpilot like-target`
  - like confirm: `REDDIT_PERMALINK='<url>' REDDIT_CONFIRM_LIKE=1 scripts/threadpilot like-target`
- Posting:
  - comment dry-run: `REDDIT_THING_ID=t3_xxxxx REDDIT_PERMALINK='<url>' REDDIT_TEXT='draft' REDDIT_DRY_RUN=1 scripts/threadpilot post-comment`
  - comment publish: `REDDIT_THING_ID=t3_xxxxx REDDIT_PERMALINK='<url>' REDDIT_TEXT='approved' scripts/threadpilot post-comment`
  - direct post command is available through `scripts/threadpilot post ...`
- Warmup scheduling:
  - random warmup runner: `ops/openclaw/warmup_random.sh`
  - cron template: `ops/openclaw/reddit_cli.cron`

## Should-Do Operating Sequence

1. Validate session first with `whoami`. Login only if missing/expired.
2. Pull subreddit rules before drafting text.
3. Run discovery/reporting (`read`, `search`) and review account state (`my-*`) before engagement.
4. Use dry-run previews for likes/comments before any publish action.
5. Require explicit confirmation before likes and duplicate-prone posts.
6. Use random warmup cadence and jitter for recurring automation.

## Warmup and Scheduler Guidance

- Use `ops/openclaw/warmup_random.sh` for randomized low-risk warmup actions:
  - read/search by default
  - account review actions only when `REDDIT_WARMUP_ENABLE_ACCOUNT_ACTIONS=1`
  - optional subscribe/like/post actions only when env flags are explicitly enabled
- Add jitter with `REDDIT_WARMUP_JITTER_SEC`.
- Keep posting off by default in unattended runs; enable only with explicit environment config.

## Safety Rules

- Never execute likes without `REDDIT_CONFIRM_LIKE=1` (or dry-run preview).
- Keep duplicate-post protection enabled unless user explicitly confirms override.
- Pull rules before generating AI copy and enforce user confirmation before publish.
