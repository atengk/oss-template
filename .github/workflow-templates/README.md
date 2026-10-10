# GitHub Actions 工作流模版库 (Workflow Templates)

本目录为不同技术栈与业务场景提供标准、开箱即用的 GitHub Actions 流水线参考模版。

> [!NOTE] **为什么放在本目录？**
> GitHub Actions 引擎**仅会自动执行** `.github/workflows/` 顶层目录下的工作流。
> 存放在 `.github/workflow-templates/` 下的模版文件**绝不会被自动触发**，可安全作为团队资产库进行版本化纳管与参考引用。

---

## 📁 模版全景索引

### 1. 语言生态专用流水线 (`languages/`)

针对主流语言生态（Java / Node.js / Go / Python / Rust）封装开箱即用的完整流水线套件（每个语言严格保持完整的 4 文件自包含结构）：

| 语言生态 | 目录 | 持续集成 (CI) | GitHub 发版与产物挂载 (Release) | 生态包发布 (Publish) | 容器镜像构建 (Docker) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Java** | [`languages/java/`](./languages/java/) | [`ci.yml`](./languages/java/ci.yml): PR 门禁、Maven 构建、测试、Spotless 格式检查 | [`release.yml`](./languages/java/release.yml): 双通道发版、git-cliff 日志、JAR 产物与 Checksums 挂载 | [`publish.yml`](./languages/java/publish.yml): Sonatype Central Portal (Maven Central) 发布 | [`docker.yml`](./languages/java/docker.yml): Spring Boot 多架构 Docker 镜像构建 (GHCR) |
| **Node.js** | [`languages/node/`](./languages/node/) | [`ci.yml`](./languages/node/ci.yml): PR 门禁、pnpm 缓存、TS 编译、ESLint、Vitest | [`release.yml`](./languages/node/release.yml): 双通道发版、git-cliff 日志、离线 TGZ 包与 Checksums 挂载 | [`publish.yml`](./languages/node/publish.yml): npm 官方仓库发布 (Trusted Publishing / Token) | [`docker.yml`](./languages/node/docker.yml): 前端 / Node 应用容器镜像构建 (GHCR) |
| **Go** | [`languages/go/`](./languages/go/) | [`ci.yml`](./languages/go/ci.yml): PR 门禁、依赖缓存、golangci-lint、竞态测试 | [`release.yml`](./languages/go/release.yml): 双通道发版、git-cliff 日志、二进制产物与 Checksums 挂载 | [`publish.yml`](./languages/go/publish.yml): GoReleaser 全平台二进制交叉编译与分发 | [`docker.yml`](./languages/go/docker.yml): 轻量化多架构 Docker 镜像构建 (GHCR) |
| **Python** | [`languages/python/`](./languages/python/) | [`ci.yml`](./languages/python/ci.yml): PR 门禁、pip 缓存、Ruff 代码检查、pytest 测试 | [`release.yml`](./languages/python/release.yml): 双通道发版、git-cliff 日志、sdist/wheel 与 Checksums 挂载 | [`publish.yml`](./languages/python/publish.yml): PyPI 官方包发布 (Trusted Publishing OIDC) | [`docker.yml`](./languages/python/docker.yml): 容器化应用打包与发布 (GHCR) |
| **Rust** | [`languages/rust/`](./languages/rust/) | [`ci.yml`](./languages/rust/ci.yml): PR 门禁、rust-cache 缓存、Clippy 扫描、fmt | [`release.yml`](./languages/rust/release.yml): 双通道发版、git-cliff 日志、Release 二进制与 Checksums 挂载 | [`publish.yml`](./languages/rust/publish.yml): Crates.io 官方发布与预编译二进制附件挂载 | [`docker.yml`](./languages/rust/docker.yml): 极简多架构 Docker 镜像构建 (GHCR) |

---

### 2. 通用生产上线部署流水线 (`deployments/`)

针对目标环境解耦设计，覆盖云主机、容器集群、边缘云平台与公有云基础设施的一键部署上线（最后一公里）：

| 部署目标 | 模版文件 | 适用场景 | 核心机制 |
| :--- | :--- | :--- | :--- |
| **GitHub Pages** | [`deployments/deploy-github-pages.yml`](./deployments/deploy-github-pages.yml) | 静态前端 / 文档站点 (Vite/Astro/MkDocs/mdBook) | 编译静态产物并上传部署至 GitHub 官方 Pages 服务（零外部依赖） |
| **云主机 / VPS** | [`deployments/deploy-ssh-docker-compose.yml`](./deployments/deploy-ssh-docker-compose.yml) | 单机 / 中小微服务 / 自建节点 | SSH 远端执行 `docker compose pull && up -d` 滚动更新，免 sshd AcceptEnv 限制 |
| **Kubernetes 集群** | [`deployments/deploy-k8s-kubectl.yml`](./deployments/deploy-k8s-kubectl.yml) | 企业级云原生容器集群 | 支持声明式 `set image` 与重启 `rollout restart` 双模式，含健康就绪探测 |
| **通用 Webhook** | [`deployments/deploy-webhook.yml`](./deployments/deploy-webhook.yml) | Portainer / Watchtower / 宝塔 / 自建面板 | 发送标准 HTTP POST Webhook 回调通知目标运维平台拉取镜像并部署 |
| **AWS S3 & CloudFront** | [`deployments/deploy-aws-s3-cloudfront.yml`](./deployments/deploy-aws-s3-cloudfront.yml) | 企业级前端 / 静态网站 / 全球 CDN | 产物增量同步至 S3 存储桶，自动触发 CloudFront 全节点缓存失效刷新 |
| **Vercel** | [`deployments/deploy-vercel.yml`](./deployments/deploy-vercel.yml) | Next.js / Nuxt / 全栈前端 | 预览环境 (Preview) 自动部署 + 主干生产环境 (`--prod`) 极速分发 |
| **Cloudflare Pages** | [`deployments/deploy-cloudflare-pages.yml`](./deployments/deploy-cloudflare-pages.yml) | 现代化前端静态 / 边缘应用 | 利用 Wrangler 将构建产物部署至 Cloudflare 全球边缘网络 |
| **Cloudflare Workers** | [`deployments/deploy-cloudflare-workers.yml`](./deployments/deploy-cloudflare-workers.yml) | 边缘 Serverless API / 轻量服务端 (Hono 等) | 利用 Wrangler 自动化编译并发布边缘函数至 Cloudflare 全球网络 |

---

## 🚀 30 秒开箱指引

当你在具体项目中需要启用流水线时，只需将对应模版拷贝至 `.github/workflows/`：

### 示例 1：开箱即用后端微服务（Java 完整四件套 + VPS 部署）
```bash
# 1. 拷贝 Java 专属完整套件 (CI、GitHub Release、Maven Central 发布、Docker 构建)
cp .github/workflow-templates/languages/java/ci.yml .github/workflows/ci.yml
cp .github/workflow-templates/languages/java/release.yml .github/workflows/release.yml
cp .github/workflow-templates/languages/java/publish.yml .github/workflows/publish.yml
cp .github/workflow-templates/languages/java/docker.yml .github/workflows/docker.yml

# 2. 拷贝生产部署流水线
cp .github/workflow-templates/deployments/deploy-ssh-docker-compose.yml .github/workflows/deploy-prod.yml
```

### 示例 2：全栈前端应用 / 文档站点（Node.js CI + GitHub Pages 部署）
```bash
# 1. 拷贝 CI 门禁与 GitHub Release 发版
cp .github/workflow-templates/languages/node/ci.yml .github/workflows/ci.yml
cp .github/workflow-templates/languages/node/release.yml .github/workflows/release.yml

# 2. 拷贝静态页面部署流水线
cp .github/workflow-templates/deployments/deploy-github-pages.yml .github/workflows/deploy-pages.yml
```

### 示例 3：开源 SDK / 库发布（以 Python / npm 发布为例）
```bash
# 拷贝官方包仓库自动发布流水线 (打 Tag 时与根目录 release.yml 自动协同)
cp .github/workflow-templates/languages/python/publish.yml .github/workflows/publish.yml
```

---

## 🛡️ GitHub Environment 生产安全门禁 (Protection Rules)

部署模版已全量接入标准化声明：
```yaml
environment:
  name: production
  url: https://your-domain.com
```

### 如何启用人工审批门禁（推荐）：
1. 在 GitHub 仓库导航栏进入 **Settings -> Environments**；
2. 点击 **New environment** 并命名为 `production`；
3. 勾选 **Required reviewers**，指定团队负责人或 Tech Lead 作为审批人；
4. 勾选 **Deployment branches**，仅允许 `main` 或 `master` 分支触发部署；
5. （可选）将生产敏感凭据配置在 **Environment secrets** 中，实现生产凭据与开发环境彻底物理隔离。

---

## 🔐 常用 GitHub Secrets 配置对照表

流水线遵循安全最小权限基准，大部分基础能力依赖内置 `${{ secrets.GITHUB_TOKEN }}`。根据选用的分发与部署场景，需在仓库 `Settings -> Secrets and variables -> Actions` 中按需注入对应凭据：

### 1. 发布至中心包管理仓库凭据

| 平台 / 生态 | Secret 名称 | 说明与获取方式 |
| :--- | :--- | :--- |
| **发版级联 (可选)** | `RELEASE_PAT` | 具有 `repo` 权限的 GitHub 个人访问令牌 (PAT)，配置后可在网页端手动发版时突破 GitHub 原生防死循环限制，自动级联触发生态发布与 Docker 镜像构建 |
| **Maven Central** | `CENTRAL_USERNAME` / `CENTRAL_PASSWORD` | Sonatype Central Portal 账号令牌 (Portal Token) |
| **Maven GPG 签名** | `MAVEN_GPG_PRIVATE_KEY` / `MAVEN_GPG_PASSPHRASE` | 用于构件签名的 ASCII-armored GPG 私钥文本与密码 |
| **npm** | `NPM_TOKEN` | npmjs.com 自动化访问令牌（或使用 OIDC Trusted Publishing） |
| **PyPI** | *建议使用 OIDC* | 推荐配置 PyPI Trusted Publisher（免静态 Secret），或设置 `PYPI_API_TOKEN` |
| **Crates.io** | `CARGO_REGISTRY_TOKEN` | crates.io 个人账户下生成的 API Token |

### 2. 远端主机与集群部署凭据

| 部署目标 | Secret 名称 | 说明与获取方式 |
| :--- | :--- | :--- |
| **SSH 主机连接** | `SSH_HOST` / `SSH_USERNAME` / `SSH_PRIVATE_KEY` | 目标服务器公网 IP/域名、登录用户、免密私钥（RSA/Ed25519） |
| **SSH 端口 (可选)** | `SSH_PORT` | 默认为 22，如修改过安全端口需配置 |
| **Kubernetes** | `KUBECONFIG` | 集群管理员或发布专用 ServiceAccount 的 Kubeconfig 文本 |
| **Webhook 回调** | `WEBHOOK_URL` / `WEBHOOK_TOKEN` (可选) | 目标运维平台 (Portainer/Watchtower/宝塔等) 部署 Webhook 与认证令牌 |
| **AWS S3 & CloudFront** | `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `S3_BUCKET_NAME` / `CLOUDFRONT_DISTRIBUTION_ID` | 具有 S3 同步与 CloudFront 失效权限的 IAM 凭据与资源标识 |
| **Vercel** | `VERCEL_TOKEN` / `VERCEL_ORG_ID` / `VERCEL_PROJECT_ID` | Vercel 账号 Access Token 及项目配置参数 |
| **Cloudflare (Pages/Workers)** | `CLOUDFLARE_API_TOKEN` / `CLOUDFLARE_ACCOUNT_ID` | 具有 Cloudflare Pages / Workers 编辑权限的 API 令牌与账户 ID |
