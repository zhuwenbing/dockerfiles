#!/usr/bin/env bash
# 单次签到：随机延迟后调用 signin.sh（含 Server酱 通知）
set -euo pipefail
cd /app

# 加载入口脚本生成的运行变量（crond 不会继承容器 ENV）
if [ -f /app/cron.env ]; then
  set -a
  . /app/cron.env
  set +a
fi

if [ "${NO_JITTER:-0}" != "1" ]; then
  MIN="${JITTER_MIN:-60}"
  MAX="${JITTER_MAX:-840}"
  if [ "$MAX" -gt "$MIN" ] 2>/dev/null; then
    WAIT=$((RANDOM % (MAX - MIN + 1) + MIN))
  else
    WAIT="$MIN"
  fi
  echo "随机等待 ${WAIT}s 后开始签到..."
  sleep "$WAIT"
fi

exec bash /app/signin.sh "${AUTH_DIR:-/app/auths}"
