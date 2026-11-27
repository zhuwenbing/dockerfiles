#!/bin/sh
# trae-signin 容器入口：准备凭证、配置定时任务并启动 crond
set -eu

AUTH_DIR="${AUTH_DIR:-/app/auths}"
mkdir -p "$AUTH_DIR"

# 首次运行可用 TRAE_AUTH_JSON 注入单个账号的凭证；
# 如果目录里已经有凭证（通常来自挂载卷），则保留文件，避免覆盖刷新后的 token。
if [ -n "${TRAE_AUTH_JSON:-}" ]; then
  if ! ls "$AUTH_DIR"/trae-*.json >/dev/null 2>&1; then
    umask 077
    printf '%s\n' "$TRAE_AUTH_JSON" > "$AUTH_DIR/trae-1.json"
    echo "已从 TRAE_AUTH_JSON 生成 $AUTH_DIR/trae-1.json"
  else
    echo "检测到已有凭证文件，忽略 TRAE_AUTH_JSON（保留刷新后的 token）"
  fi
fi

if ! ls "$AUTH_DIR"/trae-*.json >/dev/null 2>&1; then
  echo "错误：未找到 $AUTH_DIR/trae-*.json" >&2
  echo "请挂载凭证目录：-v /path/to/auths:/app/auths" >&2
  echo "或设置 TRAE_AUTH_JSON 环境变量（仅首次启动有效）" >&2
  exit 1
fi

chmod 600 "$AUTH_DIR"/trae-*.json 2>/dev/null || true

if [ -z "${SERVERCHAN_SENDKEY:-}" ]; then
  echo "提示：未设置 SERVERCHAN_SENDKEY，签到正常执行但没有通知"
fi

# crond 启动的任务通常不会继承容器 ENV，这里把运行所需变量落到文件，
# 由 run.sh 在每次签到前 source。
ENV_FILE=/app/cron.env
umask 077
{
  echo "export TZ='${TZ:-Asia/Shanghai}'"
  echo "export SERVERCHAN_API='${SERVERCHAN_API:-https://sctapi.ftqq.com}'"
  echo "export SERVERCHAN_SENDKEY='${SERVERCHAN_SENDKEY:-}'"
  echo "export BARK_URL='${BARK_URL:-}'"
  echo "export JITTER_MIN='${JITTER_MIN:-60}'"
  echo "export JITTER_MAX='${JITTER_MAX:-840}'"
  echo "export SIGNIN_BIN='/app/signin'"
  echo "export AUTH_DIR='${AUTH_DIR}'"
} > "$ENV_FILE"
chmod 600 "$ENV_FILE"

# 单次执行模式：适合交给宿主机 cron / 其他调度器
if [ "${RUN_ONCE:-0}" = "1" ]; then
  echo "RUN_ONCE=1，立即执行一次签到..."
  NO_JITTER=1 /app/run.sh
  exit $?
fi

# 容器内定时：默认北京时间 08:10 主签到、16:10 兜底
SCHEDULE="${SCHEDULE:-10 8 * * *;10 16 * * *}"
: > /etc/crontabs/root
printf '%s\n' "$SCHEDULE" | tr ';' '\n' | while IFS= read -r spec; do
  [ -n "$spec" ] || continue
  echo "$spec /app/run.sh >> /proc/1/fd/1 2>&1" >> /etc/crontabs/root
done

echo "已配置定时任务："
cat /etc/crontabs/root

exec crond -f -l 8 -c /etc/crontabs
