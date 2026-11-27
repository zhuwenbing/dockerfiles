#!/usr/bin/env bash
# 本地构建 trae-signin 镜像
set -euo pipefail
cd "$(dirname "$0")"

IMAGE="${1:-trae-signin:latest}"

docker build \
  --build-arg TRAE_SIGNIN_REPO="${TRAE_SIGNIN_REPO:-https://github.com/zhuwenbing/trae-signin.git}" \
  --build-arg TRAE_SIGNIN_REF="${TRAE_SIGNIN_REF:-main}" \
  --build-arg CACHEBUST="${CACHEBUST:-$(date +%s)}" \
  -t "$IMAGE" .

echo "已构建：$IMAGE"
