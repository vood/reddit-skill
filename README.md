# Reddit Skill (ThreadPilot)

Full Reddit operations skill powered by [`threadpilot`](https://github.com/vood/threadpilot): login, warmup, discovery, reporting, subscribing, liking, and posting with explicit safety gates.

Created by the founder of [clawmaker.dev](https://clawmaker.dev), [writingmate.ai](https://writingmate.ai), [aidictation.com](https://aidictation.com), and [mentioned.to](https://mentioned.to).

## What This Skill Can Do

- Login/session validation:
  - `login`, `whoami`
- Account activity reporting:
  - `my-comments`, `my-replies`, `my-posts`, `my-subreddits`
- Discovery and keyword research:
  - `read`, `search`
- Subreddit intelligence:
  - `rules` (pull subreddit posting rules)
- Growth actions:
  - `subscribe` (with dry-run support)
  - `like` / `like-target` (human confirmation required)
- Publishing:
  - `post` (direct)
  - `post-comment` wrapper (duplicate-protected, preview/publish flow)
- Warmup automation:
  - random action runner: `ops/openclaw/warmup_random.sh`
  - scheduler templates: `ops/openclaw/reddit_cli.cron`

## What It Should Do (Recommended Flow)

1. Start every session with `whoami`.
2. If logged out, run `login` and keep one persistent browser profile.
3. Before writing content, pull subreddit rules via `rules`.
4. Discover and shortlist targets using `read` and `search`.
5. Use dry-run for likes/comments before publishing.
6. Require explicit human confirmation for engagement actions.
7. Run warmup with randomized cadence and jitter.

## Repo Layout

- `SKILL.md`: skill trigger + operating guidance
- `scripts/threadpilot`: main launcher with safety wrappers
- `scripts/reddit-cli`: compatibility alias
- `bin/REFERENCE.md`: binary source reference (release URL pattern)
- `ops/openclaw/reddit_cli.cron`: cron examples
- `ops/openclaw/warmup_random.sh`: random warmup runner

## Installation

```bash
git clone https://github.com/vood/reddit-skill.git
cd reddit-skill
```

No bundled executables are required in repo. `scripts/threadpilot` will:

1. use `THREADPILOT_BIN` if provided
2. use cached versioned binary from `.threadpilot/bin/<version>/`
3. use system `threadpilot` from `PATH`
4. download release binary from `vood/threadpilot`
5. fall back to source build if download fails

## Browser Compatibility

This setup is no longer tied to only locally launched Chrome.

It works with any Chromium-compatible browser that exposes CDP / DevTools, including:

- Chrome / Chromium
- Chrome with `--remote-debugging-port`
- browser profiles managed outside the skill
- GoLogin (by passing its connection URL)

Examples:

```bash
GOLOGIN_WS_URL='<gologin-connect-url>' scripts/threadpilot whoami
REDDIT_BROWSER_DEBUG_URL='http://127.0.0.1:9222' scripts/threadpilot whoami
```

## Quick Start

```bash
# validate session
scripts/threadpilot whoami

# login when needed
scripts/threadpilot login

# pull rules before authoring
scripts/threadpilot rules --subreddit ChatGPT

# discovery
scripts/threadpilot read --subreddit ChatGPT --sort new --limit 10
scripts/threadpilot search --query "agent workflows" --subreddit ChatGPT --limit 10

# account state
scripts/threadpilot my-comments --limit 20
scripts/threadpilot my-replies --limit 20
scripts/threadpilot my-posts --limit 20
scripts/threadpilot my-subreddits --limit 50
```

## Liking, Posting, Subscribing

Subscribe dry-run:

```bash
scripts/threadpilot subscribe --subreddit ChatGPT --dry-run
```

Subscribe execute:

```bash
scripts/threadpilot subscribe --subreddit ChatGPT
```

Like preview:

```bash
REDDIT_PERMALINK='<url>' REDDIT_DRY_RUN=1 scripts/threadpilot like-target
```

Like confirm:

```bash
REDDIT_PERMALINK='<url>' REDDIT_CONFIRM_LIKE=1 scripts/threadpilot like-target
```

Comment preview:

```bash
REDDIT_THING_ID=t3_xxxxx REDDIT_PERMALINK='<url>' REDDIT_TEXT='draft text' REDDIT_DRY_RUN=1 scripts/threadpilot post-comment
```

Comment publish:

```bash
REDDIT_THING_ID=t3_xxxxx REDDIT_PERMALINK='<url>' REDDIT_TEXT='approved text' scripts/threadpilot post-comment
```

## Warmup Automation

Run one randomized warmup action:

```bash
ops/openclaw/warmup_random.sh
```

Enable optional actions via env:

- `REDDIT_WARMUP_ENABLE_ACCOUNT_ACTIONS=1` (includes `my-comments`, `my-replies`, `my-posts`, `my-subreddits`)
- `REDDIT_WARMUP_ENABLE_SUBSCRIBE=1` with `REDDIT_WARMUP_SUBSCRIBE_SUBREDDIT=<name>`
- `REDDIT_WARMUP_ENABLE_LIKE=1` with `REDDIT_PERMALINK=<url>` and `REDDIT_CONFIRM_LIKE=1`
- `REDDIT_WARMUP_ENABLE_POST=1` with `REDDIT_THING_ID`, `REDDIT_PERMALINK`, `REDDIT_TEXT`
- `REDDIT_WARMUP_JITTER_SEC=900` for randomized delay

## Reporting Examples

Keyword report file:

```bash
scripts/threadpilot search --query "agent workflows" --subreddit ChatGPT --limit 25 > reports/chatgpt-agent-workflows.txt
```

Subreddit scan report:

```bash
scripts/threadpilot read --subreddit ChatGPT --sort top --limit 25 > reports/chatgpt-top.txt
```

## Environment Variables

- Runtime/binary:
  - `THREADPILOT_BIN`
  - `THREADPILOT_CACHE_DIR`
  - `THREADPILOT_RELEASE_BASE_URL`
  - `THREADPILOT_VERSION` (default: `v0.2.1`)
  - `THREADPILOT_REPO`
  - `THREADPILOT_REF`
  - `THREADPILOT_SOURCE_DIR`
- Reddit/session:
  - `REDDIT_PROXY`
  - `REDDIT_USER_AGENT`
  - `REDDIT_ACCESS_TOKEN`
  - `REDDIT_BROWSER_PROFILE`
  - `REDDIT_BROWSER_WS_URL`
  - `REDDIT_BROWSER_DEBUG_URL`
  - `REDDIT_HEADLESS`
  - `REDDIT_LOGIN_TIMEOUT_SEC`
  - `REDDIT_HOLD_ON_ERROR_SEC`
  - `REDDIT_CHROME_PATH`
- External browser / GoLogin:
  - `THREADPILOT_BROWSER_WS_URL`
  - `THREADPILOT_BROWSER_DEBUG_URL`
  - `GOLOGIN_WS_URL`
  - `GOLOGIN_WS_ENDPOINT`
  - `GOLOGIN_DEBUG_URL`
- Safety controls:
  - `REDDIT_DRY_RUN`
  - `REDDIT_CONFIRM_LIKE`
  - `REDDIT_CONFIRM_DOUBLE_POST`
- Warmup controls:
  - `REDDIT_WARMUP_SUBREDDIT`
  - `REDDIT_WARMUP_QUERY`
  - `REDDIT_WARMUP_LIMIT`
  - `REDDIT_WARMUP_JITTER_SEC`
  - `REDDIT_WARMUP_ENABLE_ACCOUNT_ACTIONS`
  - `REDDIT_WARMUP_ENABLE_SUBSCRIBE`
  - `REDDIT_WARMUP_SUBSCRIBE_SUBREDDIT`
  - `REDDIT_WARMUP_ENABLE_LIKE`
  - `REDDIT_WARMUP_ENABLE_POST`

## Scheduler

Use the template in:

- [`ops/openclaw/reddit_cli.cron`](ops/openclaw/reddit_cli.cron)

It includes:

- daily session checks
- random warmup runs
- optional confirmed like/post jobs

## Compatibility

- Preferred: `scripts/threadpilot`
- Alias: `scripts/reddit-cli`
