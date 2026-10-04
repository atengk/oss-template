# 贡献指南 (Contributing Guide)

感谢你关注并愿意为本项目贡献力量！为了保持高效协作与高质量的代码维护，请在提交代码前阅读以下规范。

---

## 1. 协作与分支模型

本项目遵循标准的 **GitHub Flow** 工作流：

1. **Fork 本仓库** 到你个人的 GitHub 账号；
2. **基于 `main` 分支拉取新的特性分支**：
   ```bash
   git checkout -b feat/your-feature-name
   # 或者缺陷修复分支
   git checkout -b fix/issue-description
   ```
3. 在本地完成修改，确保自测通过并补充相应测试用例；
4. 提交更改并推送到你的远程分支：
   ```bash
   git push origin feat/your-feature-name
   ```
5. 在 GitHub 上向本仓库的 `main` 分支发起 **Pull Request**。

---

## 2. Commit 提交信息规范

本项目遵循 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/) 规范，统一采用以下格式：

```text
<type>(<scope>): <subject>
```

### 常用类型说明

| 类型 | 说明 | 示例 |
| :--- | :--- | :--- |
| `feat` | 新增功能或特性 | `feat(auth): 支持 OAuth2 登录授权` |
| `fix` | 缺陷与 Bug 修复 | `fix(parser): 修复空字符串解析导致空指针的问题` |
| `docs` | 仅文档更新或修改 | `docs: 完善快速开始与环境配置文档` |
| `style` | 代码格式调整（空格、分号等，不影响逻辑） | `style: 优化代码排版与换行` |
| `refactor` | 代码重构（既非新增特性也非修复缺陷） | `refactor(core): 抽取公共工具类` |
| `perf` | 性能优化 | `perf(cache): 引入本地二级缓存提升吞吐量` |
| `test` | 增加或重构单元测试与集成测试 | `test: 补充用户服务边界条件测试用例` |
| `build` | 构建系统、外部依赖或脚手架调整 | `build: 升级依赖版本至最新稳定版` |
| `ci` | CI/CD 流水线与 GitHub Actions 脚本修改 | `ci: 优化 release 自动化发版流程` |
| `chore` | 其他琐碎杂项（不改动源码与测试） | `chore: 更新 .gitignore 忽略规则` |

---

## 3. Pull Request 流程

- 发起 PR 时，请按模版完整填写变更背景、解决的问题以及关联的 Issue（如 `close #12`）；
- 确保 CI 流水线测试全部处于通过（绿灯）状态；
- 代码审查（Code Review）提出修改意见后，在原分支继续提交即可自动同步至 PR；
- PR 合并后，特性分支将被删除。

---

## 4. 版本发版机制与发布说明

本项目通过 GitHub Actions 实现了自动化发版体系：

1. **日常归纳**：合并至 `main` 分支的 PR 会由 GitHub 自动纳入发布日志统计；
2. **触发发版**：当需要正式发布新版本时，仅需打上符合语义化版本规范的 Git Tag 并推送：
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. **自动化流水线**：
   - 自动生成格式化的 GitHub Release 发布笔记（包含该版本所有特性、修复与贡献者名单）；
   - 自动挂载打包物至 Release 附件；
   - 如已配置官方中心仓库（npm / Maven / PyPI），将自动触发分发。

### 中心仓库发布凭据 (Secrets) 参考

如需发布至官方包管理仓库，请在仓库的 **Settings -> Secrets and variables -> Actions** 中配置对应凭证：

- **npm**: 推荐配置 [npm Trusted Publishing (OIDC)](https://docs.npmjs.com/trusted-publishers)，或配置 `NPM_TOKEN`；
- **Maven Central**: 配置 `OSSRH_USERNAME`、`OSSRH_TOKEN`、`MAVEN_GPG_PRIVATE_KEY`、`MAVEN_GPG_PASSPHRASE`；
- **PyPI**: 推荐使用官方 [PyPI Trusted Publisher (OIDC)](https://docs.pypi.org/trusted-publishers/)，免配静态密钥；
- **Docker 镜像**:
  - **GHCR (推荐)**: 默认直接使用系统内置 `GITHUB_TOKEN`，零 Secret 配置；
  - **Docker Hub**: 配置 `DOCKERHUB_USERNAME` 与 `DOCKERHUB_TOKEN`。
