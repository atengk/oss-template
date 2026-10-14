# GitHub Actions 工作流模版库 (Workflow Templates)

本目录为不同技术栈与业务场景提供标准、开箱即用的 GitHub Actions 工业级流水线参考模版库。

> [!IMPORTANT] **⚠️ 下游项目使用核心原则：请参考本目录模版，勿直接使用根目录工作流！**
> - **根目录 `.github/workflows/`**：仅用于 `oss-template` 模板工程自身的 Shell 脚本自检与轻量通用发版底座，**默认不包含**任何具体语言（Java/Node/Go/Python/Rust）的单测、静态扫描、制品打包与中心仓库（PyPI/npm/Maven/Docker）分发逻辑；
> - **本目录 `.github/workflow-templates/`**：才是下游各业务项目应当引用的**正式生产级流水线资产库**。

> [!NOTE] **为什么放在本目录？**
> GitHub Actions 引擎**仅会自动执行** `.github/workflows/` 顶层目录下的工作流。
> 存放在 `.github/workflow-templates/` 下的模版文件**绝不会被自动触发**，可安全作为团队资产库进行版本化纳管与按需复制引用。

---

## 📁 模版全景索引

### 1. 语言生态专用流水线 (`languages/`)

针对主流语言生态（Java / Node.js / Go / Python / Rust）封装工业级**二元标准模型（Dual-Workflow Standard）**流水线套件：每个语言严格保持 `ci.yml`（持续集成与质量门禁）与 `release.yml`（统合发版编排器）两大核心工作流，彻底杜绝多流并发竞争、重复测试与包抢发冲突。

| 语言生态 | 目录 | 持续集成质量门禁 (CI) | 统合发版编排流水线 (Unified Release) |
| :--- | :--- | :--- | :--- |
| **Java** | [`languages/java/`](./languages/java/) | [`ci.yml`](./languages/java/ci.yml): PR 门禁、动态路径短路、Java LTS (17/21) 兼容性矩阵测试、终审看板 | [`release.yml`](./languages/java/release.yml): 单次构建、JAR 与 Checksums、GitHub Release、Maven Central 发布 (GPG)、Spring Boot 多架构 Docker (GHCR) |
| **Node.js** | [`languages/node/`](./languages/node/) | [`ci.yml`](./languages/node/ci.yml): PR 门禁、动态路径短路、Node.js (18/20/22) 兼容性矩阵、ESLint/Typecheck、终审看板 | [`release.yml`](./languages/node/release.yml): 单次打包 (pnpm pack)、TGZ 与 Checksums、GitHub Release、npm 官方发布 (OIDC)、Node.js 多架构 Docker (GHCR) |
| **Go** | [`languages/go/`](./languages/go/) | [`ci.yml`](./languages/go/ci.yml): PR 门禁、动态路径短路、golangci-lint 扫描、跨版本数据竞态测试 (-race)、终审看板 | [`release.yml`](./languages/go/release.yml): 交叉编译全平台二进制、Checksums、GitHub Release、Go 多架构 Docker (GHCR) |
| **Python** | [`languages/python/`](./languages/python/) | [`ci.yml`](./languages/python/ci.yml): PR 门禁、动态路径短路、Ruff 规范检查、pytest 跨版本 (3.10~3.12) 测试矩阵、终审看板 | [`release.yml`](./languages/python/release.yml): 单次构建 (sdist/wheel)、Checksums、GitHub Release、PyPI 官方发布 (OIDC)、Python 多架构 Docker (GHCR) |
| **Rust** | [`languages/rust/`](./languages/rust/) | [`ci.yml`](./languages/rust/ci.yml): PR 门禁、动态路径短路、Clippy 严苛扫描 (-D warnings)、rustfmt、Cargo 单元测试、终审看板 | [`release.yml`](./languages/rust/release.yml): 生产级二进制编译、Checksums、GitHub Release、Crates.io 官方发布、Rust 多架构 Docker (GHCR) |

> [!TIP] **统合发版编排器 (`release.yml`) 核心设计优势**：
> - **Build Once, Distribute Everywhere**：全流程先执行发版前置门禁测试（测试未过绝对熔断阻断），随后执行单次编译打包并生成 SHA-256 校验和清单，产物上传为不可变 Artifact；下游的 GitHub Release、包管理器（PyPI/npm等）与 Docker 镜像构建**全部复用同一份制品**，彻底消灭算力重复浪费与产物哈希漂移；
> - **零外部 Token 安全流**：无需配置高危个人访问令牌（PAT），全链路依托 GitHub Actions 原生短效 `GITHUB_TOKEN` 与现代免密 OIDC (Trusted Publishing) 自动流转；
> - **标签防污染策略**：严控 Docker 镜像标签，仅在正式语义化 Tag（非 pre-release）发版时打上 `:latest`，保护生产环境不受开发快照污染。

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

## 🚀 极速开箱与下游集成指引

### 🤖 方式一：AI Agent 跨项目智能集成（强烈推荐）

在新项目或存量项目中，无需手动克隆或下载本仓库，直接复制开源模版 GitHub 地址与下方 Prompt 发送给 AI 助手（如 Antigravity、Cursor、Claude Code、GitHub Copilot）：

> **📋 Agent 跨项目智能集成 Prompt (直接复制发给 AI)：**
> ```text
> 请参考开源模版仓库 https://github.com/atengk/oss-template ，为我当前的新项目智能集成生产级 GitHub Actions 流水线与工程规范：
> 
> 【关键注意】：下游使用时必须参考目标模版库的 .github/workflow-templates/ 目录，绝对不要直接使用其根目录的 .github/workflows/！
> 
> 请执行以下操作：
> 1. 自动识别我当前项目的技术栈（Python / Java / Go / Node.js / Rust）与主干分支名称（main 或 master）；
> 2. 从目标模版库的 .github/workflow-templates/languages/<当前语言>/ 中提取 ci.yml 与 release.yml，复制并落地为我项目中的 .github/workflows/ci.yml 和 .github/workflows/release.yml；
> 3. （可选部署）如果我需要自动化部署，请从 .github/workflow-templates/deployments/ 选用对应部署模版写入 .github/workflows/；
> 4. 引入工程规范底座：同步引入 .cliff.toml、.githooks/commit-msg、.github/dependabot.yml 与社区治理文档模版；
> 5. 执行 git config core.hooksPath .githooks 激活提交守门；若无需本地脚本，请保持 scripts/ 吃灰或删除。
> ```

---

### 🛠️ 方式二：命令行手动复制启用

当你在具体项目中需要启用流水线时，只需将对应模版拷贝并**覆盖**至 `.github/workflows/`：

> [!NOTE] **关于覆盖根目录已有工作流**：
> 根目录 `.github/workflows/` 下默认仅提供了通用轻量底座（通用 ShellCheck 门禁与通用 git-cliff 发版底座）。
> 若要启用各语言专属的深度能力（单测执行、发行包编译与全自动化发版），直接将语言专属模版（`ci.yml` 与 `release.yml`）**覆盖复制**至 `.github/workflows/` 即可。

### 示例 1：后端微服务（Java 完整套件 + VPS 部署）
```bash
# 1. 拷贝 Java 专属完整套件 (CI 质量门禁 + 统合发版编排器)
cp .github/workflow-templates/languages/java/ci.yml .github/workflows/ci.yml
cp .github/workflow-templates/languages/java/release.yml .github/workflows/release.yml

# 2. 拷贝生产部署流水线
cp .github/workflow-templates/deployments/deploy-ssh-docker-compose.yml .github/workflows/deploy-prod.yml
```

### 示例 2：全栈前端应用 / 文档站点（Node.js CI + GitHub Pages 部署）
```bash
# 1. 拷贝 CI 门禁与统合发版
cp .github/workflow-templates/languages/node/ci.yml .github/workflows/ci.yml
cp .github/workflow-templates/languages/node/release.yml .github/workflows/release.yml

# 2. 拷贝静态页面部署流水线
cp .github/workflow-templates/deployments/deploy-github-pages.yml .github/workflows/deploy-pages.yml
```

### 示例 3：开源 Python SDK / CLI / MCP Server 发布
```bash
# 拷贝 Python 二元流水线套件 (CI 质量门禁 + PyPI / Release / Docker 统合发版)
cp .github/workflow-templates/languages/python/ci.yml .github/workflows/ci.yml
cp .github/workflow-templates/languages/python/release.yml .github/workflows/release.yml
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
