# AI Agent 协作规范模板体系 (AI Agent Templates)

本目录为 `oss-template` 沉淀的**工业级多技术栈 AI Agent 协作规范与行为准则模板库**。无论下游项目采用何种技术栈，均可**零环境门槛、零脚本依赖**，直接选用对应模版开箱即用。

---

## 1. 模板选型矩阵 (Template Matrix)

| 目录 | 适用技术栈与框架 | 包含规约范围 | 预置产物路径 |
| :--- | :--- | :--- | :--- |
| **`universal/`** | 跨语言通用（CLI / 基础库 / 任意项目） | 交互交付、注释契约、健壮性底线、Git 纪律、工具链安全、机密脱敏、10 项自检清单 | [universal/AGENTS.md](./universal/AGENTS.md) |
| **`go/`** | **Go (Go 1.22+)** | 通用基准 + Goroutine 退出机制、`%w` 错误链与 `errors.Is`、生产零主动 panic、`cmd/internal/pkg` 结构、代差排斥清单 | [go/AGENTS.md](./go/AGENTS.md) |
| **`rust/`** | **Rust (Edition 2021 + Tokio)** | 通用基准 + 生产零裸 unwrap/expect、`?` 与 Result 优雅传播、`tokio::sync::Mutex` 跨 await、spawn_blocking 隔离、Clippy 零警告 | [rust/AGENTS.md](./rust/AGENTS.md) |
| **`java/`** | **Java (Spring Boot 3.x + JDK 17/21)** | 通用基准 + 构造器注入、DTO/VO/PO 模型隔离、`Result<T>` 统一包装、`jakarta.*` 命名空间、代差排斥清单 | [java/AGENTS.md](./java/AGENTS.md) |
| **`python/`** | **Python (FastAPI + Pydantic v2 + Python 3.10+)** | 通用基准 + 现代联合类型（`X \| None`）、Pydantic v2 强契约、`async def` 异步非阻塞防线、Depends 注入、代差排斥清单 | [python/AGENTS.md](./python/AGENTS.md) |
| **`vue/`** | **Vue 3 (TypeScript + Vite + TailwindCSS + Pinia)** | 通用基准 + `<script setup lang="ts">`、泛型 Props/Emits、响应式安全（解构防丢失）、生命周期清理、代差排斥清单 | [vue/AGENTS.md](./vue/AGENTS.md) |
| **`react/`** | **React (Next.js App Router + TypeScript + TailwindCSS)** | 通用基准 + Server Components 优先、客户端组件下沉、Hooks 真实依赖（禁 eslint-disable）、不可变状态更新、Zustand | [react/AGENTS.md](./react/AGENTS.md) |
| **`flutter/`** | **Flutter (Dart 3 + Flutter 3.x 跨平台)** | 通用基准 + 异步裂隙守卫（`!context.mounted`）、控制器成对注销（`dispose`）、`const` 渲染优化、独立类拆解、Dart 3 模式匹配、禁 `!` 解包 | [flutter/AGENTS.md](./flutter/AGENTS.md) |

> [!NOTE]
> 每个语言目录下的 `AGENTS.md` 均为**独立、自洽的全量规范产物**（已内嵌完整的通用基线与该语言专属特化），下游直接单文件拷用即可，无需多文件拼装。

---

## 2. 下游项目快速接入指南 (How to Use)

你可以根据习惯自由选择 **命令行复制** 或 **AI 对话引导** 两种方式之一：

### 模式一：一键单行复制 (Direct Copy)

在从 `oss-template` 派生的下游项目根目录下，直接复制对应技术栈的模板文件覆盖至根目录 `AGENTS.md`：

```bash
# 1. 通用技术栈 (跨语言/任意项目)
cp .agents/templates/universal/AGENTS.md ./AGENTS.md

# 2. Go (Go 1.22+)
cp .agents/templates/go/AGENTS.md ./AGENTS.md

# 3. Rust (Rust 2021 + Tokio)
cp .agents/templates/rust/AGENTS.md ./AGENTS.md

# 4. Java (Spring Boot 3)
cp .agents/templates/java/AGENTS.md ./AGENTS.md

# 5. Python (FastAPI)
cp .agents/templates/python/AGENTS.md ./AGENTS.md

# 6. Vue 3 (TypeScript + Vite)
cp .agents/templates/vue/AGENTS.md ./AGENTS.md

# 7. React (Next.js App Router)
cp .agents/templates/react/AGENTS.md ./AGENTS.md

# 8. Flutter (Dart 3 移动端/跨平台)
cp .agents/templates/flutter/AGENTS.md ./AGENTS.md
```

---

### 模式二：AI 提示词引导初始化 (AI-Assisted Initialization)

在你的 AI 编程助手（如 Cursor、Windsurf、Claude Code、Gemini 等）新会话中，直接发送以下提示词，让 AI 协助完成规范注入与个性化微调：

#### 通用技术栈提示词：
```text
请参考 .agents/templates/universal/AGENTS.md 中的工业级规范，为当前项目初始化根目录的 AGENTS.md。保持其通用基线中的工程质量、Git 提交与自检清单要求，并结合当前项目实际情况做最小适配。
```

#### Go (Go 1.22+) 提示词：
```text
请参考 .agents/templates/go/AGENTS.md 中的规范，为当前项目配置根目录的 AGENTS.md。严格遵守其 Goroutine 生命周期退出机制、%w 错误链与 errors.Is 匹配、生产零主动 panic 以及 defer 安全判空要求。
```

#### Rust (Edition 2021 + Tokio) 提示词：
```text
请参考 .agents/templates/rust/AGENTS.md 中的规范，为当前项目配置根目录的 AGENTS.md。严格遵守其生产代码零裸 unwrap/expect、? 运算符优雅传播、跨 await 锁安全（tokio::sync::Mutex）与 spawn_blocking 异步隔离要求。
```

#### Java (Spring Boot 3) 提示词：
```text
请参考 .agents/templates/java/AGENTS.md 中的规范，为当前项目配置根目录的 AGENTS.md。严格遵守其构造器注入、DTO/VO/Entity 三层模型隔离、jakarta.* 命名空间及代差排斥清单要求。
```

#### Python (FastAPI) 提示词：
```text
请参考 .agents/templates/python/AGENTS.md 中的规范，为当前项目配置根目录的 AGENTS.md。严格遵守 Python 3.10+ 原生类型、Pydantic v2 规范、async def 异步非阻塞防线及分层解耦要求。
```

#### Vue 3 (TypeScript) 提示词：
```text
请参考 .agents/templates/vue/AGENTS.md 中的规范，为当前项目配置根目录的 AGENTS.md。严格遵守 <script setup lang="ts">、泛型类型契约、Props 解构响应式安全及生命周期清理要求。
```

#### React (Next.js App Router) 提示词：
```text
请参考 .agents/templates/react/AGENTS.md 中的规范，为当前项目配置根目录的 AGENTS.md。严格遵守 Server Components 优先架构、客户端组件下沉原则、Hooks 真实完整依赖以及不可变状态更新要求。
```

#### Flutter (Dart 3) 提示词：
```text
请参考 .agents/templates/flutter/AGENTS.md 中的规范，为当前项目配置根目录的 AGENTS.md。严格遵守其异步裂隙守卫（!context.mounted）、控制器与订阅在 dispose() 中成对清理、UI 强制 const 优化、独立 StatelessWidget 拆解及零 ! 强行解包要求。
```

---

## 3. 可选工程扩展规范 (Optional Engineering Extensions)

针对**大型基础设施套件、复杂业务系统、SDK 库或系统级重构**等高熵场景，模板库提供了两套解耦的高级工程扩展规范，存放于 `extensions/` 目录。它们可按需与上述任意技术栈的 `AGENTS.md` 叠加组合使用：

| 扩展文件 | 核心职责与设计原则 | 适用场景 |
| :--- | :--- | :--- |
| [**`workflow-blueprint-spec-ticket.md`**](./extensions/workflow-blueprint-spec-ticket.md) | **复杂任务推进范式**：设立宏观任务触发门槛，严格执行 **总纲蓝图 (Blueprint) ➔ 规格契约 (Spec) ➔ 工单切片 (Ticket)** 三级演进流水线与双重人类确认门禁（Approval Gates）。 | 全新子系统/微服务构建、跨模块系统级重构、协议栈迁移 |
| [**`quality-tested-docs.md`**](./extensions/quality-tested-docs.md) | **文档工程与测试保真准则**：坚持“无未文档化功能 (Zero Undocumented Feature)”红线；确立“先行测试 ➔ 提炼主干 ➔ 剥离测试噪声 ➔ 规范生产调用”契约与代码块追溯注记（`Tested-By`）。 | 基础设施套件、公共工具库、前后端业务系统 |

### 组合使用方法：

#### 方法 A：单行追加至根目录规范 (Append to AGENTS.md)
在选择基础语言模板后，可直接将所需扩展内容追加到项目的 `AGENTS.md` 尾部：
```bash
# 示例：在 Go 规范基础上叠加「复杂任务工作流」与「可测文档保真」
cp .agents/templates/go/AGENTS.md ./AGENTS.md
cat .agents/templates/extensions/workflow-blueprint-spec-ticket.md >> ./AGENTS.md
cat .agents/templates/extensions/quality-tested-docs.md >> ./AGENTS.md
```

#### 方法 B：AI 提示词引导组合集成 (AI Prompt)
```text
请参考 .agents/templates/universal/AGENTS.md（或对应技术栈模板），并叠加 .agents/templates/extensions/workflow-blueprint-spec-ticket.md 与 quality-tested-docs.md 中的高级扩展规范，为当前项目生成一份兼具大任务三级推进门禁与测试保真文档要求的 AGENTS.md。
```

---

## 4. 规范设计原则 (Design Principles)

1. **下游零门槛 (Zero Friction)**：无需运行 Python、Node 或 Bash 预处理，单文件开箱即用。
2. **严防语言倒灌 (No Cross-Contamination)**：通用基线绝不泄漏任何特定语言的专有概念；各语言特化集中收敛在特化章节与代差排斥清单中。
3. **闭环可自检 (Pre-flight Self-Audit)**：文末均附带 AI 交付前自检清单，将抽象原则转化为可被大模型执行前心智核对的具体卡点。
