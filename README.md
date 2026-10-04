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
</p>

---

## 📖 项目简介

> 💡 **名词释义**：
> **OSS** 是 **Open Source Software（开源软件 / 开源项目）** 的国际通用缩写（⚠️ 注意：并非云厂商的“对象存储服务”）。
> `oss-template` 旨在为后端（Java/Go/Python等）、前端（Vue/React/Node等）以及 CLI 工具提供标准化的现代开源工程底座与开箱即用的 GitHub 自动化流水线。


---

## ✨ 核心特性

- 🎯 **技术栈纯净解耦**：无侵入式设计，不绑定任何特定语言运行时，保留统一的工程底座；
- 🚀 **自动化发版流水线**：打 Tag（如 `v1.0.0`）自动触发发版、自动提取 PR/Commit 生成精美更新日志、自动挂载打包物附件；
- 📦 **全场景分发体系预备**：内置 Maven Central、npmjs、PyPI、Docker (GHCR) 以及 GoReleaser (CLI) 与 GitHub Pages (前端/文档) 等 6 大分发流水线参考与凭据规范；
- 🛡️ **规范化工作流**：支持 Conventional Commits 提交规范、预置结构化 Issue 反馈与标准 PR 审查模版；
- 🧹 **极简整洁**：全仓库仅保留必需的核心文件，无冗余配置与环境负担。

---

## 🛠️ 快速开始：基于本模版初始化新项目

### 1. 使用模版创建仓库
在 GitHub 仓库首页点击绿色的 **「Use this template」 -> 「Create a new repository」** 创建你的新项目仓库，或直接点击下方快捷入口：

> 🚀 **[点击一键基于本模版创建新仓库 (One-Click Generate)](https://github.com/atengk/oss-template/generate)**

### 2. 全局替换占位符
将新仓库克隆到本地后，在 IDE 中全局搜索并替换以下占位符：

| 占位符 | 说明 | 示例 |
| :--- | :--- | :--- |
| `{{PROJECT_NAME}}` | 新项目名称 | `my-awesome-tool` |
| `{{PROJECT_DESCRIPTION}}` | 项目一句话中文描述 | `高性能分布式任务调度组件` |
| `{{GITHUB_USERNAME}}` | 你的 GitHub 用户名或组织名 | `Ateng` |
| `{{AUTHOR_NAME}}` | 作者称谓 | `Ateng` |
| `{{CURRENT_YEAR}}` | 当前年份 | `2026` |

### 3. 配置业务构建与测试插槽
打开 [`.github/workflows/ci.yml`](./.github/workflows/ci.yml)，找到对应的技术栈区域（Node.js / Java / Go / Python），解除对应步骤的注释并填入你的构建/测试命令即可。

### 4. 开启 GitHub Actions 写入权限（关键避坑）
GitHub 新建仓库默认的 Actions 权限为只读。为确保发版流水线能自动创建 GitHub Release 并上传附件，请前往：
- 仓库 **Settings -> Actions -> General -> Workflow permissions**；
- 勾选 **Read and write permissions** 并保存。

---

## 🚀 版本发版与发布指南

当项目准备发布新版本时，无需手动在网页编写 Release 笔记，只需在本地推送一个语义化版本号的 Git Tag：

```bash
# 1. 确保本地 main 分支代码最新且 CI 绿灯通过
git checkout main
git pull origin main

# 2. 打标签并推送到 GitHub (支持 v1.0.0, v1.0.0-beta.1 等)
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions 将会自动执行 [`.github/workflows/release.yml`](./.github/workflows/release.yml)：
1. 提取自上一版本以来的全部合并 PR 与提交记录；
2. 自动生成 GitHub Release 详情并归类贡献者；
3. 将打包产物自动挂载至 Release 页面附件（若配置了构建步骤）；
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
│   │   └── feature_request.md      # 新特性建议模版
│   ├── workflows/
│   │   ├── ci.yml                  # 业务构建测试（含 PR 标题规范校验）
│   │   └── release.yml             # 自动化发版、生成更新日志与分发流水线（含 6 大场景分发参考）
│   └── PULL_REQUEST_TEMPLATE.md    # Pull Request 提交模版
├── .cliff.toml                     # git-cliff 变更日志提取与分类配置
├── .dockerignore                   # Docker 镜像构建上下文忽略配置
├── .editorconfig                   # 跨编辑器编码与缩进规范
├── .gitattributes                  # 跨平台换行符归一化配置 (强制 LF)

├── .gitignore                      # 跨语言通用忽略配置
├── CONTRIBUTING.md                 # 贡献指南与 Commit 提交规范
├── LICENSE                         # 开源许可证 (Apache-2.0)
└── README.md                       # 项目主文档
```


---

## 🤝 参与贡献

欢迎任何形式的贡献与建议！请在提交代码前仔细阅读我们的 [贡献指南 (CONTRIBUTING.md)](./CONTRIBUTING.md)。

---

## 📄 开源许可证

本项目基于 [Apache License 2.0](./LICENSE) 协议开源。
