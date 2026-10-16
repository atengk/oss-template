# 全局协作规范与 AI Agent 行为准则 (Universal Guidelines)

---

## 1. 交互与交付规范 (Interaction & Delivery)

- **语言规范**：沟通对话、方案设计、代码注释与任务卡片统一使用自然中文；代码标识符、系统命令、专有名词与报错堆栈保持原始英文。
- **文件优先交付 (File-First Delivery)**：
  - 结构化交付物（架构方案、API 契约、数据字典等）与超过 50 行的新建代码一律直接写入文件，避免在会话中倾泻长文本；
  - 文档间互链 100% 采用相对路径（`./`、`../`），外部信源采用标准 HTTPS URL；禁止在交付物正文中写入绝对路径或本地盘符。

---

## 2. 提交规范与门面工具 (Conventional Commits & Tooling)

- **精准路径暂存 (Safe Path Staging)**：暂存必须显式指定目标文件（`git add <file-path>`）；禁止全量通配（`git add .` 或 `-A`）。
- **提交门面脚本优先**：统一通过 [scripts/commit.sh](./scripts/commit.sh) 执行提交：
  - **格式规范**：严格遵循 Conventional Commits：`<type>(<scope>): <清晰中文描述>`；多项改动使用 `-l/--item` 逐项列出；
  - **工单闭环**：使用 `-c/--close`（闭环）或 `-i/--issue`（关联），底层按行生成符合 RFC 5147 的 Git Trailer：
    ```text
    Closes #12
    Closes #13
    Refs #14
    ```
  - **提交演练**：提交前可运行 `bash scripts/commit.sh -n` 预览校验生成的 Header、Body 与 Git Trailer。

---

## 3. 特性即文档准则 (Doc-as-Feature & Per-Ticket Sync)

- **同工单/同提交交付**：新增功能、对外接口与配置改造，必须在同一 PR 与提交中同步交付对应文档与用例。
- **三板斧验收标准 (Completion Criteria)**：
  1. **场景痛点**：一句话阐明解决的业务或工程问题；
  2. **最小用例**：提供复制即用的最小配置、命令或示例代码；
  3. **预期呈现**：明确给出调用输出、API 响应或数据形态。
- **准出底线**：缺少配套文档与可运行用例的代码改动，一律视为未达验收标准。

---

## 4. 信息安全与机密脱敏红线 (Zero-Secret Invariant)

- **凭据语义化占位**：源码、配置文件、技术文档、脚本及提交信息中，凭据字段统一使用大写占位符（如 `YOUR_API_TOKEN`、`user@example.com`）或环境变量（如 `${DEPLOY_TOKEN}`、`${API_KEY}`）。
- **零真实凭据落盘**：禁止在代码库任何位置硬编码真实密码、API Key、Token、私钥或个人隐私数据。
