# OSS Template (Open Source Software Template)

<p align="center">
  <strong>通用的 GitHub 开源项目基础模版仓库（开箱即用集成 CI/CD、Docker 与工程化规范）</strong>
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
- 🛡️ **工程脚本三剑客（人机协同兼顾）**：内置初始化向导 `scripts/setup.sh`、规范提交助手 `scripts/commit.sh` 及发版防呆脚本 `scripts/release.sh`，全面支持交互式向导与静默参数（`-y`），既方便人工沉浸交互，又无缝兼容 AI Agent 与 CI 自动化调用；
- 📦 **全场景分发体系预备**：内置 Maven Central、npmjs、PyPI、Docker (GHCR) 以及 GoReleaser (CLI) 与 GitHub Pages (前端/文档) 等 6 大分发流水线参考与凭据规范；
- 🧹 **极简整洁**：全仓库仅保留必需的核心工程规范与脚本，无冗余配置与第三方运行时负担。

---

## 🛠️ 快速开始：基于本模版初始化新项目

### 1. 使用模版创建仓库
在 GitHub 仓库首页点击绿色的 **「Use this template」 -> 「Create a new repository」** 创建你的新项目仓库，或直接点击下方快捷入口：

> 🚀 **[点击一键基于本模版创建新仓库 (One-Click Generate)](https://github.com/atengk/oss-template/generate)**

### 2. 全局替换模版默认信息
克隆新仓库到本地后，推荐直接运行内置的初始化向导 [scripts/setup.sh](./scripts/setup.sh) 一键完成项目元数据与链接替换：

```bash
# 方式 A：交互式向导（推荐人工使用，自动探测当前环境默认值并引导确认）
bash scripts/setup.sh

# 方式 B：命令行静默执行（适合 AI 智能助手或 CI 自动化脚本执行）
bash scripts/setup.sh -u my-org -r my-awesome-tool -a "Zhang San" -y
```

> 💡 你也可以在 IDE 中全局搜索以下默认值进行手动替换：

| 搜索内容（当前默认值） | 替换为你自己的内容 | 说明 | 示例 |
| :--- | :--- | :--- | :--- |
| `atengk/oss-template` | `your-username/your-repo` | 仓库全路径（更新 Badge 徽标与链接） | `my-org/my-awesome-tool` |
| `atengk` | `your-username` | 你的 GitHub 用户名或组织名 | `my-org` |
| `oss-template` | `your-repo` | 你的新项目仓库名称 | `my-awesome-tool` |
| `Ateng` | `Your Name` | 作者称谓 / 版权所有者 | `Zhang San` |
| `security@example.com` | `your-security-email` | 安全漏洞私密联络邮箱 (SECURITY.md) | `security@my-org.com` |

### 3. 配置业务构建与测试插槽
打开 [`.github/workflows/ci.yml`](./.github/workflows/ci.yml)，找到对应的技术栈区域（Node.js / Java / Go / Python），解除对应步骤的注释并填入你的构建/测试命令即可。

### 4. 开启 GitHub Actions 写入权限（关键避坑）

> [!IMPORTANT]
> **发版流水线必须的前置配置**：GitHub 新建仓库默认的 Actions 权限为只读。为确保打 Tag 时发版流水线能自动创建 GitHub Release 并上传附件，必须开启写入权限：
> 1. 前往仓库 **Settings -> Actions -> General -> Workflow permissions**；
> 2. 勾选 **Read and write permissions** 并点击保存。

### 5. 日常规范化提交 (使用 commit.sh)
日常编码后，推荐直接运行内置的规范提交助手 [scripts/commit.sh](./scripts/commit.sh)，规范组装 Conventional Commits 提交信息：

```bash
# 交互式向导（推荐日常使用，编号菜单引导选择类型、范围与描述）
bash scripts/commit.sh

# 非交互式命令行（适合 AI 智能助手或熟手快速提交）
git add <file-path>
bash scripts/commit.sh -t feat -s core -m "新增功能描述" -p -y
```

> 💡 更多提交选项与规范细节，请参阅 [贡献指南 (CONTRIBUTING.md)](./CONTRIBUTING.md#2-commit-提交信息规范)。

---

## 🚀 版本发版与发布指南

本项目支持**双通道自动化发版**，无需手动在网页编辑 Release 笔记：

### 推荐：使用本地发版防呆脚本
通过内置脚本进行自动化前置自检（分支合规、工作区清洁度、远端同步状态与 Tag 重名检测），并智能推导下一个语义化版本：

```bash
# 1. 安全演练模式（强烈推荐：仅检查和预览拟执行命令，零污染 Git 历史）
bash scripts/release.sh --dry-run

# 2. 交互式发版向导（自动推导 Patch / Minor / Major 版本或自定义输入）
bash scripts/release.sh

# 3. 指定版本号发版（支持 -y 跳过交互确认，方便 AI Agent / CI 自动化调用）
bash scripts/release.sh v1.0.0
bash scripts/release.sh v1.0.0 -y
```

> 💡 **云端与原生替代方案**：
> - **云端网页触发**：访问仓库 **Actions -> Release -> Run workflow**，输入版本号即可一键自动打标并发版；
> - **原生 Git 命令**：确保工作区干净后直接运行 `git tag -a v1.0.0 -m "Release v1.0.0" && git push origin v1.0.0`。
> 
> 更多多语言版本文件递增（Maven/npm/Cargo/Poetry 等）配置说明，请参阅 [贡献指南 (CONTRIBUTING.md)](./CONTRIBUTING.md#4-版本发版机制与发布说明)。

GitHub Actions 将会自动执行 [`.github/workflows/release.yml`](./.github/workflows/release.yml)：
1. 提取自上一版本以来的全部合并 PR 与提交记录；
2. 自动生成 GitHub Release 详情并归类贡献者；
3. 将打包产物与 `checksums.txt` 安全校验清单自动挂载至 Release 页面附件（若配置了构建步骤）；
4. 分发至官方中心仓库或平台（若配置了 Maven / npm / PyPI / Docker / GoReleaser / Pages 等发布 Job）。

> 💡 **版本更新日志 (Changelog)**：
> 每一个正式版本的详细变动明细、关联 Issue 与贡献者致谢均由系统自动维护，可直接前往 [GitHub Releases](https://github.com/atengk/oss-template/releases) 查看最新记录。

---

## 📂 仓库目录结构

```text
.
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md           # Bug 缺陷反馈模版
│   │   ├── feature_request.md      # 新特性建议模版
│   │   └── config.yml              # Issue 治理配置 (关闭空白 Issue & 导流 Discussions)
│   ├── workflows/
│   │   ├── ci.yml                  # 业务构建测试（含 PR 标题规范校验与脚本语法守门）
│   │   └── release.yml             # 自动化发版、生成更新日志与分发流水线（含双通道发版与 6 大场景分发参考）
│   └── PULL_REQUEST_TEMPLATE.md    # Pull Request 提交模版
├── scripts/
│   ├── commit.sh                   # 规范化提交助手 (支持交互向导与非交互式/AI自动化调用)
│   ├── release.sh                  # 全生命周期发版防呆脚本 (含 Pre-flight 自检、回滚防御与生态插槽)
│   └── setup.sh                    # 模版项目一键初始化向导 (自动替换占位符，支持人工与 AI 命令行调用)
├── .cliff.toml                     # git-cliff 变更日志提取与分类配置
├── .dockerignore                   # Docker 镜像构建上下文忽略配置
├── .editorconfig                   # 跨编辑器编码与缩进规范
├── .gitattributes                  # 跨平台换行符归一化配置 (强制 LF)
├── .gitignore                      # 跨语言通用忽略配置
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
