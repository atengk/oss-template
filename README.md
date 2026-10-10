# OSS Template (Open Source Software Template)

<p align="center">
  <strong>通用的 GitHub 开源项目基础模版仓库（开箱即用集成 CI/CD、自动发版、Docker 与工程化规范）</strong>
</p>

<p align="center">
  <a href="https://github.com/atengk/oss-template/actions/workflows/ci.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/atengk/oss-template/ci.yml?branch=main&label=CI&style=flat-square" alt="CI Status" />
  </a>
  <a href="https://github.com/atengk/oss-template/releases">
    <img src="https://img.shields.io/github/v/release/atengk/oss-template?style=flat-square" alt="Release" />
  </a>
  <a href="./LICENSE">
    <img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=flat-square" alt="License" />
  </a>
  <a href="./CONTRIBUTING.md">
    <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square" alt="PRs Welcome" />
  </a>
</p>

---

## 📖 项目简介

> 💡 **名词释义**：
> **OSS** 是 **Open Source Software（开源软件 / 开源项目）** 的国际通用缩写（⚠️ 注意：并非云厂商的“对象存储服务”）。
> `oss-template` 旨在为后端（Java/Go/Python等）、前端（Vue/React/Node等）以及 CLI 工具提供标准化的现代开源工程底座与开箱即用的 GitHub 自动化流水线。

---

## ✨ 核心特性

- 🎯 **技术栈纯净解耦**：无侵入式设计，不绑定任何特定语言运行时，保留统一的工程底座；
- 🚀 **双通道自动化发版体系**：支持本地脚本驱动与云端网页调度（`workflow_dispatch`），打 Tag 自动触发发版、自动提取 PR/Commit 生成精美更新日志、自动挂载打包物附件；
- 🛡️ **双重提交守门与工程脚本（人机协同兼顾）**：内置原生 Git 钩子 `.githooks/commit-msg`（零外部依赖守门 Conventional Commits）、规范提交助手 `scripts/commit.sh`、初始化向导 `scripts/setup.sh` 及发版防呆脚本 `scripts/release.sh`，全面支持交互式向导与静默参数（`-y`），既方便人工沉浸交互，又无缝兼容 AI Agent 与 CI 自动化调用；
- 🔒 **工业级 CI/CD 权限加固与多生态依赖巡检**：遵循最小权限原则（Least Privilege）严格收敛流水线权限，预置主流包管理器（npm/Maven/pip/gomod/Cargo/Docker）Dependabot 自动化依赖安全巡检插槽；
- 📦 **全场景分发体系预备**：内置 Maven Central (Portal)、npmjs、PyPI、Docker (GHCR) 以及 GoReleaser (CLI) 与 GitHub Pages (前端/文档) 等 6 大分发流水线参考与凭据规范；
- 🧹 **极简整洁**：全仓库仅保留必需的核心工程规范与脚本，无冗余配置与第三方运行时负担。

---

<!-- TEMPLATE_SETUP_START -->
## 🛠️ 快速开始与接入方案

本项目不仅支持**从零创建新项目**，还完美支持为**已有存量项目无损引入现代开源规范**。请根据你的场景选择：

---

### 🌟 场景一：基于本模版初始化全新项目 (New Project)

#### 1. 使用模版创建仓库
在 GitHub 仓库首页点击绿色的 **「Use this template」 -> 「Create a new repository」** 创建你的新项目仓库，或直接点击下方快捷入口：

> 🚀 **[点击一键基于本模版创建新仓库 (One-Click Generate)](https://github.com/atengk/oss-template/generate)**

#### 2. 全局替换模版默认信息 (三选一)

- **🤖 方式 A：让 AI 编程助手一键初始化（强烈推荐！）**
  如果你使用 Antigravity、Cursor、GitHub Copilot 或 Claude Code 等 AI 助手，直接复制下方指令发送给 AI 即可一步到位：

  > **📋 一键初始化 Prompt (直接复制发给 AI)：**
  > ```text
  > 请读取当前项目，帮我将该开源模版初始化为我的全新独立项目：
  > - GitHub 组织或用户名：<your-username>
  > - 仓库/项目名称：<your-repo>
  > - 作者姓名/版权所有者：<Your Name>
  > - 安全漏洞披露邮箱：<security@your-domain.com>
  > 
  > 执行要求：
  > 1. 全局精准替换上述元数据（包括 README.md、CODE_OF_CONDUCT.md、CONTRIBUTING.md、SECURITY.md、LICENSE、.github/ISSUE_TEMPLATE/config.yml 等）；
  > 2. 配置本地 Git 规范提交钩子：执行 git config core.hooksPath .githooks；
  > 3. 运行 bash scripts/setup.sh --clean -y 自动完成模版教学章节裁剪、清理 setup.sh 并创建初始提交（若偏好纯原生零脚本模式，可使用 --clean-all 一键彻底删除 scripts/ 目录）；
  > 4. 【可选极简选项】：如果我不打算使用 scripts/ 目录下的辅助脚本，请同时将 scripts/ 目录完整物理删除（本项目完全支持纯原生 Git 与 GitHub Web 网页端零脚本开发）。
  > ```

- **🛠️ 方式 B：使用内置向导脚本 (scripts/setup.sh)**
  克隆新仓库到本地后，运行内置向导自动替换并激活 Git 钩子：
  ```bash
  # 交互式向导 (引导输入，支持初始化完成后一键自毁向导脚本并创建初始提交)
  bash scripts/setup.sh

  # 命令行静默执行并在完成后自动清理向导脚本、注入业务骨架并创建初始提交
  bash scripts/setup.sh -u my-org -r my-awesome-tool --clean -y

  # 纯原生零脚本模式 (初始化完成后自动裁剪教学并彻底删除 scripts/ 目录)
  bash scripts/setup.sh -u my-org -r my-awesome-tool --clean-all -y

  # 强制重新配置/覆盖更新已有设置 (若此前已初始化过)
  bash scripts/setup.sh -u my-org -r my-awesome-tool -f -y
  ```

- **✍️ 方式 C：纯手动或 IDE 全局搜索替换**
  在 IDE 中全局搜索替换 `atengk/oss-template`、`atengk`、`oss-template`、`Ateng` 与 `security@example.com`，随后在终端执行 `git config core.hooksPath .githooks`。

---

### 📦 场景二：已有存量项目一键引入本套件 (Adopt in Existing Projects)

如果你已有正在运行的存量项目，希望引入本套件的**自动化发版、更新日志提取、提交守护与社区治理规范**，同时**绝不影响现有业务代码、不破坏历史提交、不覆盖已有配置**：

#### 🤖 方式 A：AI 外科手术式无损接入 (强烈推荐！)
复制下方指令发送给你项目中的 AI 编程助手（Antigravity / Cursor / Claude Code 等），AI 将自动阅读你的技术栈并执行安全增量缝合：

> **📋 存量项目接入 Prompt (直接复制发给 AI)：**
> ```text
> 请参考开源模版 https://github.com/atengk/oss-template 的工程化规范，帮我为当前已有项目无损引入现代开源工程规范：
> 
> 执行原则：【外科手术式增量缝合，严禁破坏/覆盖任何现有业务代码、现有业务文档与现有构建逻辑】
> 
> 具体执行步骤：
> 1. 资产与分支识别：探测当前项目的实际技术栈（Node.js/Java/Go/Python等）与主干分支名称（main 或 master）；
> 2. 引入提交守门构件：
>    - 引入 .githooks/commit-msg 守门 Conventional Commits；
>    - 引入 scripts/commit.sh 作为可选日常提交助手；
> 3. 引入自动化发版体系：
>    - 引入 .cliff.toml（适配 v?[0-9].* 标签正则）与 scripts/release.sh；
>    - 在 scripts/release.sh 的 custom_bump_version 中按需解除本技术栈的版本号更新命令；
>    - 引入 .github/workflows/release.yml 双通道发版流水线；
> 4. 社区治理与配置增量安全合并：
>    - 引入 CODE_OF_CONDUCT.md、CONTRIBUTING.md、SECURITY.md 与 Issue/PR 模板；
>    - 安全合并 .editorconfig、.gitattributes 与 .gitignore（仅增量追加规则，保留原有配置）；
>    - 在当前 CI 流水线中增量追加 PR 标题规范校验与 ShellCheck 检查步骤；
> 5. 文档微创维护：
>    - 100% 完整保留我原有的 README.md 业务描述与架构说明，仅在顶部补充 CI 与 Release 状态徽标，并在贡献章节链接至 CONTRIBUTING.md；
> 6. 软着陆引导：提醒我在 GitHub 仓库 Settings 中开启「Squash and merge」并将默认信息设为 PR Title，实现团队零侵入无感过渡。
> ```

#### 🛠️ 方式 B：手动增量复制引入
若偏好手动接入，只需将本模版的以下构件按需复制到你的项目中：
1. **发版与日志**：复制 `.cliff.toml`、`scripts/release.sh` 与 `.github/workflows/release.yml`；
2. **规范提交**：复制 `.githooks/commit-msg` 并执行 `git config core.hooksPath .githooks`（或直接使用 GitHub Squash Merge 软着陆）；
3. **治理文档**：复制 `CODE_OF_CONDUCT.md`、`CONTRIBUTING.md`、`SECURITY.md` 并将其中占位符更新为你自己的项目信息；
4. **工程底座配置**：按需复制或增量合并 `.editorconfig`、`.gitattributes`、`.gitignore`、`.dockerignore` 与 `.github/dependabot.yml`。

---

### ⚙️ 通用关键配置（关键避坑与日志银弹）

> [!IMPORTANT]
> **1. 开启发版流水线写入权限 (必须)**：
> GitHub 新建仓库默认的 Actions 权限为只读。为确保打 Tag 时发版流水线能自动创建 GitHub Release 并上传附件，必须开启写入权限：
> - 前往仓库 **Settings -> Actions -> General -> Workflow permissions**；
> - 勾选 **Read and write permissions** 并点击保存。
> 
> **2. 开启 Squash and merge 压缩合并 (零脚本日志银弹，强烈推荐)**：
> 如果你在日常开发中不想跑任何本地提交脚本，也不想强迫团队成员安装本地钩子，建议开启 GitHub 默认压缩合并：
> - 前往仓库 **Settings -> General -> Pull Requests**；
> - 勾选 **Allow squash merging**，并将默认提交信息设置为 **Pull request title and description**；
> - **收益**：开发者在本地无论怎么自由提交，只要通过 PR 合并，主干上的提交信息就会自动被规范的 PR 标题替换（PR 标题由 CI 自动守门），零脚本也能 100% 保证发版更新日志精美准确！

---

### 💡 日常规范化提交 (原生 Git 与可选 commit.sh)
- **方式 A (推荐日常首选)**：直接使用 IDE 图形界面或命令行原生 `git commit`（只要配置了上述 Squash and merge 或运行过 `git config core.hooksPath .githooks`，提交完全自由受控）；
- **方式 B (进阶可选工具箱)**：运行内置的规范提交助手 [scripts/commit.sh](./scripts/commit.sh)，通过编号菜单引导选择类型、范围与描述：
  ```bash
  bash scripts/commit.sh
  ```

> 💡 **关于零脚本 / 脚本吃灰模式的特别说明**：
> 本项目中所有的 `scripts/`（`commit.sh`、`release.sh`、`setup.sh`）均为**可选语法糖**！
> 即使你将它们**就放在 `scripts/` 目录中完全不跑也不删**，也**完全不会影响项目任何功能**：
> - `setup.sh` 内置了已初始化自锁检测，不会被协作者意外误跑；
> - 提交与发版完全由原生 Git 与 GitHub 网页端承接；
> - CI 流水线具备自适应容错，测试与发版 100% 畅通无阻！
<!-- TEMPLATE_SETUP_END -->

---

## 🚀 版本发版与发布指南

本项目支持多种发版路径，你可以根据习惯自由选择：

### 方式一：GitHub 网页端一键发版 (推荐首选，零脚本零终端依赖)
无需在本地敲任何命令或安装任何工具，随时随地在浏览器中即可一键发布新版本：
1. 前往 GitHub 仓库页面，点击顶部 **Actions** 标签页；
2. 在左侧选择 **GitHub Release** 流水线；
3. 点击右侧蓝色的 **Run workflow** 下拉按钮；
4. 在 **发布版本号** 输入框中填入目标版本号（如 `v1.0.0`），点击绿色按钮启动即可（流水线内置严格分支防呆校验，自动拦截非默认主干分支的误触发版，且全局发版互斥保障产物原子性）。

### 方式二：原生 Git 命令行手动打标发版 (纯原生)
确保本地最新代码已推送至 `main` 分支后，直接运行标准 Git 命令：
```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### 方式三 (进阶可选工具箱)：使用本地发版防呆脚本 (scripts/release.sh)
面向重度终端用户，提供 5 重前置防呆自检（分支合规、工作区洁净度、超前提交对齐、Tag 重名检测）与多语言工程版本文件递增（`custom_bump_version`）：
```bash
# 安全演练模式（仅检查并预览拟执行命令，零污染 Git 历史）
bash scripts/release.sh --dry-run

# 交互式发版向导（自动推导 Patch / Minor / Major 版本）
bash scripts/release.sh
```

---

GitHub Actions 将会自动执行 [`.github/workflows/release.yml`](./.github/workflows/release.yml)：
1. 提取自上一版本以来的全部合并 PR 与提交记录；
2. 自动生成 GitHub Release 详情并归类贡献者；
3. 将打包产物与 `checksums.txt` 安全校验清单自动挂载至 Release 页面附件（若配置了构建步骤）；
4. **制品分发与容器镜像解耦设计**：若需自动将产物分发至官方中心仓库（Maven Central / npm / PyPI / Crates.io 等）或构建多架构 Docker 镜像推送至 GHCR，可直接选用模版库中解耦的 `publish.yml` 与 `docker.yml`。

> 💡 **版本更新日志 (Changelog)**：
> 每一个正式版本的详细变动明细、关联 Issue 与贡献者致谢均由系统自动维护，可直接前往 [GitHub Releases](https://github.com/atengk/oss-template/releases) 查看最新记录。

---

## 🧩 GitHub Actions 流水线模版资产库 (Workflow Templates)

本项目在 [`.github/workflow-templates/`](./.github/workflow-templates/) 中沉淀了 **28 套开箱即用、自包含且经过工业级加固** 的 GitHub Actions 生产级流水线参考模版：

### 1. 5 大主流语言生态全套流水线 (`languages/`)

针对主流语言生态采用 **「4 文件自包含套件」** 设计，每个语言均拥有完整的独立闭环：

| 语言生态 | 套件路径 | 持续集成 (CI) | GitHub 发版与产物挂载 (Release) | 生态包发布 (Publish) | 容器镜像构建 (Docker) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Java** | [languages/java/](./.github/workflow-templates/languages/java/) | Maven 构建、测试、Spotless 格式检查 | 双通道发版、git-cliff 日志、JAR 产物与 Checksums | Maven Central (Sonatype Central) 发布 | Spring Boot 多架构 Docker 镜像 (GHCR) |
| **Node.js** | [languages/node/](./.github/workflow-templates/languages/node/) | pnpm 依赖缓存、TS 编译、ESLint、Vitest | 双通道发版、git-cliff 日志、离线 TGZ 与 Checksums | npm 官方仓库发布 (Provenance / Token) | 前端 / Node 应用多架构 Docker 镜像 (GHCR) |
| **Go** | [languages/go/](./.github/workflow-templates/languages/go/) | Go 依赖缓存、golangci-lint、竞态测试 | 双通道发版、git-cliff 日志、二进制产物与 Checksums | GoReleaser 交叉编译全平台二进制分发 | 极简多架构 Docker 镜像 (GHCR) |
| **Python** | [languages/python/](./.github/workflow-templates/languages/python/) | pip 缓存、Ruff 代码规范检查、pytest 测试 | 双通道发版、git-cliff 日志、sdist/wheel 与 Checksums | PyPI 官方包发布 (Trusted Publishing OIDC) | 容器化应用打包与发布 (GHCR) |
| **Rust** | [languages/rust/](./.github/workflow-templates/languages/rust/) | rust-cache 缓存、Clippy 扫描、cargo fmt | 双通道发版、git-cliff 日志、编译产物与 Checksums | Crates.io 官方发布与预编译资产挂载 | 极简多架构 Docker 镜像 (GHCR) |

### 2. 8 大通用生产上线部署流水线 (`deployments/`)

解耦目标基础设施环境，覆盖自建主机、云原生容器、边缘计算及公有云静态托管：

| 部署目标 | 模版文件 | 适用场景与核心机制 |
| :--- | :--- | :--- |
| **GitHub Pages** | [`deployments/github-pages.yml`](./.github/workflow-templates/deployments/github-pages.yml) | 静态前端 / 文档站点 (Vite/Astro/MkDocs/mdBook)，零外部依赖自动化部署 |
| **云主机 / VPS** | [`deployments/ssh-docker-compose.yml`](./.github/workflow-templates/deployments/ssh-docker-compose.yml) | 云主机远端执行 `docker compose pull && up -d` 滚动更新，支持 GHCR 登录凭证注入 |
| **Kubernetes 集群** | [`deployments/k8s-kubectl.yml`](./.github/workflow-templates/deployments/k8s-kubectl.yml) | 支持声明式更新 (`set image`) 与重启 (`rollout restart`) 双模式，含健康就绪状态探测 |
| **通用 Webhook** | [`deployments/webhook.yml`](./.github/workflow-templates/deployments/webhook.yml) | 向 Portainer / Watchtower / 1Panel / 宝塔等面板推送标准 HTTP POST 回调通知 |
| **AWS S3 & CloudFront** | [`deployments/aws-s3-cloudfront.yml`](./.github/workflow-templates/deployments/aws-s3-cloudfront.yml) | 前端产物增量同步至 S3，自动触发 CloudFront 全球边缘节点缓存刷新 (Invalidation) |
| **Vercel** | [`deployments/vercel.yml`](./.github/workflow-templates/deployments/vercel.yml) | Next.js / Nuxt / 全栈前端，支持 PR 预览环境构建与主干生产环境 (`--prod`) 部署 |
| **Cloudflare Pages** | [`deployments/cloudflare-pages.yml`](./.github/workflow-templates/deployments/cloudflare-pages.yml) | 利用 Wrangler CLI 将构建产物极速部署至 Cloudflare 全球边缘静态托管网络 |
| **Cloudflare Workers** | [`deployments/cloudflare-workers.yml`](./.github/workflow-templates/deployments/cloudflare-workers.yml) | 利用 Wrangler 自动化编译并发布边缘函数 / Serverless API (Hono 等) |

> 📖 **完整使用指引与配置详情**：请参阅 [工作流模版库专有文档 (.github/workflow-templates/README.md)](./.github/workflow-templates/README.md)。

---

## 📂 仓库目录结构

```text
.
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md           # Bug 缺陷反馈模版
│   │   ├── feature_request.md      # 新特性建议模版
│   │   └── config.yml              # Issue 治理配置 (关闭空白 Issue & 导流 Discussions)
│   ├── workflow-templates/         # 5 大主流语言完整套件 (CI/Release/Publish/Docker) 与 8 大生产部署流水线资产库
│   ├── workflows/
│   │   ├── ci.yml                  # 业务构建测试（含 PR 标题与 Shell 语法守门）
│   │   └── release.yml             # 自动化发版、提取更新日志与 Release 资产挂载（双通道驱动，生态分发解耦至模版库）
│   ├── CODEOWNERS                  # 代码属主与 PR 审阅者自动指派配置
│   ├── dependabot.yml              # GitHub Actions 及多技术栈依赖月度自动巡检配置
│   └── PULL_REQUEST_TEMPLATE.md    # Pull Request 提交模版
├── .githooks/
│   └── commit-msg                  # Git 原生提交规范守护钩子 (免外部依赖)
├── scripts/
│   ├── commit.sh                   # 规范化提交助手 (支持交互向导与非交互式/AI自动化调用)
│   ├── release.sh                  # 全生命周期发版防呆脚本 (含 Pre-flight 自检、回滚防御与生态插槽)
│   └── setup.sh                    # 模版项目一键初始化向导 (自动替换占位符，支持人工与 AI 命令行调用)
├── .cliff.toml                     # git-cliff 变更日志提取与分类配置
├── .dockerignore                   # Docker 镜像构建上下文忽略配置
├── .editorconfig                   # 跨编辑器编码与缩进规范
├── .gitattributes                  # 跨平台换行符归一化配置 (强制 LF)
├── .gitignore                      # 跨语言通用忽略配置
├── CODE_OF_CONDUCT.md              # 社区行为准则 (Contributor Covenant v2.1)
├── CONTRIBUTING.md                 # 贡献指南与 Commit 提交规范
├── LICENSE                         # 开源许可证 (Apache-2.0)
├── README.md                       # 项目主文档
└── SECURITY.md                     # 安全策略与漏洞披露指南
```

---

## 🤝 参与贡献

欢迎任何形式的贡献与建议！请在提交代码前仔细阅读我们的 [贡献指南 (CONTRIBUTING.md)](./CONTRIBUTING.md)。

---

## 📄 开源许可证

本项目基于 [Apache License 2.0](./LICENSE) 协议开源。
