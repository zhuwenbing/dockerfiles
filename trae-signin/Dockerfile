# syntax=docker/dockerfile:1

# ---- 构建阶段：从 trae-signin 源码编译签到程序 ----
FROM golang:1.23-alpine AS build

ARG TRAE_SIGNIN_REPO=https://github.com/zhuwenbing/trae-signin.git
ARG TRAE_SIGNIN_REF=main
ARG CACHEBUST=1

RUN apk add --no-cache git ca-certificates && \
    echo "cachebust=${CACHEBUST}" && \
    git clone --depth 1 --branch "${TRAE_SIGNIN_REF}" "${TRAE_SIGNIN_REPO}" /src

# 防止源码还没加入 Server酱/Bark 通知时构建出“签到成功但不通知”的镜像
RUN if ! grep -q 'SERVERCHAN_SENDKEY' /src/signin.sh; then \
      echo "错误：trae-signin 源码不支持 Server酱/Bark 通知，请先推送通知改动" >&2; \
      exit 1; \
    fi

WORKDIR /src
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/signin ./cmd/signin

# ---- 运行阶段：签到程序 + 定时任务 ----
FROM alpine:3.21

LABEL maintainer="zhuwenbing" \
      org.opencontainers.image.title="trae-signin" \
      org.opencontainers.image.description="TRAE daily sign-in with ServerChan notification" \
      org.opencontainers.image.source="https://github.com/zhuwenbing/dockerfiles"

ENV TZ=Asia/Shanghai \
    SERVERCHAN_API=https://sctapi.ftqq.com \
    SCHEDULE="10 8 * * *;10 16 * * *" \
    JITTER_MIN=60 \
    JITTER_MAX=840 \
    RUN_ONCE=0 \
    SIGNIN_BIN=/app/signin

RUN apk add --no-cache \
        bash \
        ca-certificates \
        curl \
        grep \
        sed \
        tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo "$TZ" > /etc/timezone \
    && mkdir -p /app/auths /etc/crontabs

WORKDIR /app

COPY --from=build /out/signin /app/signin
COPY --from=build /src/signin.sh /app/signin.sh
COPY run.sh /app/run.sh
COPY entrypoint.sh /app/entrypoint.sh

RUN chmod 0755 /app/signin /app/signin.sh /app/run.sh /app/entrypoint.sh

# 凭证目录需要可写：token 刷新后会原子写回 JSON
VOLUME ["/app/auths"]

ENTRYPOINT ["/app/entrypoint.sh"]
