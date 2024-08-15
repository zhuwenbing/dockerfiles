#### 简述：
1. 这是一个自用的 [IYUUPlus开发版](https://github.com/ledccn/iyuuplus-dev) Docker镜像。
2. 基础镜像为 PHP 官方镜像 php:8.3-alpine，以后会视情况进行版本升级。
3. 文件 docker-compose.yml 为容器编排示例，你可以在此基础上添加 NGINX 等反代服务器。
4. 你也可以根据 [源代码](https://github.com/zhuwenbing/dockerfiles/tree/master/iyuuplus) 自行构建镜像。

#### 镜像特点：
1. 容器启动时会自动根据所在区域决定从 GitHub 还是 Gitee 拉取 IYUUPlus 源代码。
2. IYUUPlus 代码可持久化。会在容器启动时拉取并自动判断代码是否已存在。
3. 镜像只包含 IYUUPlus 运行所需环境，取消了内置的 NGINX 和 MySQL。
