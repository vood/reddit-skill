#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLI="${REDDIT_SKILL_CLI:-$ROOT/scripts/threadpilot}"

if [[ ! -x "$CLI" ]]; then
  echo "CLI launcher not executable: $CLI"
  exit 1
fi

# Optional jitter to avoid fixed activity timestamps.
JITTER_SEC="${REDDIT_WARMUP_JITTER_SEC:-0}"
if [[ "$JITTER_SEC" =~ ^[0-9]+$ ]] && [[ "$JITTER_SEC" -gt 0 ]]; then
  sleep "$((RANDOM % (JITTER_SEC + 1)))"
fi

SUBREDDIT="${REDDIT_WARMUP_SUBREDDIT:-ChatGPT}"
QUERY="${REDDIT_WARMUP_QUERY:-agent workflows}"
LIMIT="${REDDIT_WARMUP_LIMIT:-10}"

actions=(
  "read"
  "search"
)

if [[ "${REDDIT_WARMUP_ENABLE_ACCOUNT_ACTIONS:-0}" == "1" ]]; then
  actions+=(
    "my-comments"
    "my-replies"
    "my-posts"
    "my-subreddits"
  )
fi

if [[ "${REDDIT_WARMUP_ENABLE_SUBSCRIBE:-0}" == "1" ]] && [[ -n "${REDDIT_WARMUP_SUBSCRIBE_SUBREDDIT:-}" ]]; then
  actions+=("subscribe")
fi

if [[ "${REDDIT_WARMUP_ENABLE_LIKE:-0}" == "1" ]] && [[ -n "${REDDIT_PERMALINK:-}" ]] && [[ "${REDDIT_CONFIRM_LIKE:-0}" == "1" ]]; then
  actions+=("like-target")
fi

if [[ "${REDDIT_WARMUP_ENABLE_POST:-0}" == "1" ]] && [[ -n "${REDDIT_THING_ID:-}" ]] && [[ -n "${REDDIT_TEXT:-}" ]] && [[ -n "${REDDIT_PERMALINK:-}" ]]; then
  actions+=("post-comment")
fi

if [[ ${#actions[@]} -eq 0 ]]; then
  echo "No warmup actions available"
  exit 1
fi

pick="${actions[$((RANDOM % ${#actions[@]}))]}"
echo "[warmup] action=$pick subreddit=$SUBREDDIT limit=$LIMIT"

case "$pick" in
  read)
    exec "$CLI" read --subreddit "$SUBREDDIT" --sort new --limit "$LIMIT"
    ;;
  search)
    exec "$CLI" search --query "$QUERY" --subreddit "$SUBREDDIT" --limit "$LIMIT"
    ;;
  my-comments)
    exec "$CLI" my-comments --limit "$LIMIT"
    ;;
  my-replies)
    exec "$CLI" my-replies --limit "$LIMIT"
    ;;
  my-posts)
    exec "$CLI" my-posts --limit "$LIMIT"
    ;;
  my-subreddits)
    exec "$CLI" my-subreddits --limit "$LIMIT"
    ;;
  subscribe)
    exec "$CLI" subscribe --subreddit "$REDDIT_WARMUP_SUBSCRIBE_SUBREDDIT"
    ;;
  like-target)
    exec "$CLI" like-target
    ;;
  post-comment)
    exec "$CLI" post-comment
    ;;
  *)
    echo "Unsupported action: $pick"
    exit 1
    ;;
esac
