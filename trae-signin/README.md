# trae-signin

TRAE 每日签到镜像。签到程序来自 [trae-signin](https://github.com/zhuwenbing/trae-signin) 源码，镜像内不包含登录流程。

## 特性

- 基于 trae-signin 源码编译，无第三方运行时依赖
- 内置定时任务：默认北京时间 08:10 主签到、16:10 兜底
- 签到前随机等待 1~15 分钟
- Server酱 / Bark 推送签到结果（配置哪个用哪个，可同时启用）
- 支持 amd64 / arm64
- token 刷新后自动写回挂载的凭证文件

## 构建

```bash
bash build.sh
# 或指定镜像名
bash build.sh my-registry/trae-signin:latest
```

也可以直接使用 docker build：

```bash
docker build \
  --build-arg TRAE_SIGNIN_REPO=https://github.com/zhuwenbing/trae-signin.git \
  --build-arg TRAE_SIGNIN_REF=main \
  -t trae-signin:latest .
```

> 镜像会从 `TRAE_SIGNIN_REF` 指定的分支重新拉取源码，修改 trae-signin 后需要先推送。
> 如果源码里的 `signin.sh` 还不支持 Server酱/Bark 通知，构建会直接失败，避免生成无法通知的镜像。
>
> 本地重新构建时如果源码有更新，建议带上 `--build-arg CACHEBUST=$(date +%s)` 或 `--no-cache`，避免复用旧的 clone 层。

## 运行

先在 Windows 上完成 TRAE 登录，得到 `auths/trae-*.json`，然后把整个 `auths` 目录挂载到容器：

```bash
docker run -d \
  --name trae-signin \
  --restart unless-stopped \
  -e TZ=Asia/Shanghai \
  -e SERVERCHAN_SENDKEY="SCT..." \
  -e BARK_URL="https://api.day.app/你的Key" \
  -v /path/to/auths:/app/auths \
  trae-signin:latest
```

### docker-compose

```yaml
services:
  trae-signin:
    image: <dockerhub-user>/trae-signin:latest
    container_name: trae-signin
    restart: unless-stopped
    environment:
      TZ: Asia/Shanghai
      SERVERCHAN_SENDKEY: SCT...
      BARK_URL: https://api.day.app/你的Key
      # Server酱³ 自定义端点：
      # SERVERCHAN_API: https://<uid>.push.ft07.com/send
    volumes:
      - ./auths:/app/auths
```

## 凭证

推荐挂载目录，支持多个账号（`trae-*.json`）：

```bash
-v /path/to/auths:/app/auths
```

挂载目录**必须可写**：token 刷新后会原子写回 JSON。

也可以首次启动时通过环境变量注入单个账号：

```bash
-e TRAE_AUTH_JSON='{"account":{...},"auth":{...}}'
```

如果 `/app/auths` 里已经有 `trae-*.json`，`TRAE_AUTH_JSON` 会被忽略，避免覆盖刷新后的 token。

## 环境变量

| 变量 | 默认值 | 说明 |
|---|---|---|
| `SERVERCHAN_SENDKEY` | 空 | Server酱 SendKey；不填则不推 Server酱 |
| `SERVERCHAN_API` | `https://sctapi.ftqq.com` | 自定义端点，Server酱³ 可设为 `https://<uid>.push.ft07.com/send` |
| `BARK_URL` | 空 | Bark 推送地址；不填则不推 Bark |
| `TZ` | `Asia/Shanghai` | 容器时区，影响定时任务 |
| `SCHEDULE` | `10 8 * * *;10 16 * * *` | 分号分隔的 cron 表达式 |
| `JITTER_MIN` | `60` | 随机延迟下限（秒） |
| `JITTER_MAX` | `840` | 随机延迟上限（秒） |
| `RUN_ONCE` | `0` | 设为 `1` 时立即签到一次后退出 |
| `AUTH_DIR` | `/app/auths` | 凭证目录 |
| `TRAE_AUTH_JSON` | 空 | 首次启动注入单个账号凭证 |

## 单次执行

如果不想用容器内定时，可以交给宿主机 cron：

```bash
docker run --rm \
  -e RUN_ONCE=1 \
  -e SERVERCHAN_SENDKEY="SCT..." \
  -v /path/to/auths:/app/auths \
  trae-signin:latest
```

## 日志

```bash
docker logs -f trae-signin
```

## 注意

- `auths/*.json` 包含 refreshToken 和设备私钥，注意文件权限，不要提交到 Git
- Server酱 SendKey / Bark 地址不要写进镜像或仓库
- `SERVERCHAN_SENDKEY` 与 `BARK_URL` 可只配一个，也可同时配置
- 容器内定时使用容器本地时间，默认已设置为 `Asia/Shanghai`
- 同一账号不要同时让本容器和 GitHub Actions 自动签到：refreshToken 会轮换，两边会互相顶掉，建议只保留一边自动执行
