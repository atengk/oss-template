#!/usr/bin/env bash
# ==============================================================================
# 模版初始化向导 (Template Initialization Setup Script)
#
# 一键替换模版中的组织名、仓库名、作者称谓与安全邮箱，配置 Git 钩子并支持安全自清理。
#
# @author Ateng
# @since 2026-10-09
# ==============================================================================

set -eo pipefail

# 终端色彩定义（在支持的终端下提供视觉区分，兼容非 TTY 降级）
if [ -t 1 ]; then
  COLOR_RESET="\033[0m"
  COLOR_BOLD="\033[1m"
  COLOR_GREEN="\033[32m"
  COLOR_BLUE="\033[34m"
  COLOR_YELLOW="\033[33m"
  COLOR_RED="\033[31m"
  COLOR_CYAN="\033[36m"
else
  COLOR_RESET=""
  COLOR_BOLD=""
  COLOR_GREEN=""
  COLOR_BLUE=""
  COLOR_YELLOW=""
  COLOR_RED=""
  COLOR_CYAN=""
fi

log_info() {
  printf "%b[INFO]%b %s\n" "${COLOR_BLUE}" "${COLOR_RESET}" "$1"
}

log_success() {
  printf "%b[SUCCESS]%b %s\n" "${COLOR_GREEN}" "${COLOR_RESET}" "$1"
}

log_warn() {
  printf "%b[WARN]%b %s\n" "${COLOR_YELLOW}" "${COLOR_RESET}" "$1"
}

log_error() {
  printf "%b[ERROR]%b %s\n" "${COLOR_RED}" "${COLOR_RESET}" "$1"
}

# ==============================================================================
# 1. 命令行参数解析
# ==============================================================================
NEW_OWNER=""
NEW_REPO=""
NEW_AUTHOR=""
NEW_EMAIL=""
AUTO_CONFIRM=false
DRY_RUN=false
CLEAN_AFTER_SETUP=false
CLEAN_ALL_SCRIPTS=false
FORCE_SETUP=false

show_help() {
  printf "%b\n" "用法: bash scripts/setup.sh [选项]"
  printf "%b\n" ""
  printf "%b\n" "选项说明 (支持交互向导与非交互式/AI自动化调用):"
  printf "%b\n" "  -u, --owner <owner>     GitHub 用户名或组织名 (例如 my-org)"
  printf "%b\n" "  -r, --repo <repo>       仓库/项目名称 (例如 my-awesome-tool)"
  printf "%b\n" "  -a, --author <author>   作者称谓或版权所有者 (例如 Zhang San)"
  printf "%b\n" "  -e, --email <email>     安全漏洞联络邮箱 (例如 security@my-org.com)"
  printf "%b\n" "  -f, --force             强制重新执行向导（跳过已初始化自锁检测，支持覆盖更新配置）"
  printf "%b\n" "  --clean, --self-destruct 初始化完成后裁剪 README 模版教学章节、删除 setup.sh 并自动创建初始提交"
  printf "%b\n" "  --clean-all, --no-scripts 初始化完成后裁剪模版教学章节、彻底删除 scripts/ 目录并创建初始提交（零脚本纯原生）"
  printf "%b\n" "  -y, --yes               跳过确认提示，直接执行替换 (注意: 默认不自毁，需显式加 --clean 或 --clean-all)"
  printf "%b\n" "  -n, --dry-run           演练模式，仅预览拟替换内容，不修改任何文件"
  printf "%b\n" "  -h, --help              显示帮助信息"
  printf "%b\n" ""
  printf "%b\n" "无参数运行示例 (交互向导模式):"
  printf "%b\n" "  bash scripts/setup.sh"
  printf "%b\n" ""
  printf "%b\n" "非交互式调用示例 (AI / 自动化执行):"
  printf "%b\n" "  bash scripts/setup.sh -u my-org -r my-project -a \"Zhang San\" -e \"sec@my-org.com\" -y"
  printf "%b\n" "  bash scripts/setup.sh -u my-org -r my-project --clean -y"
  printf "%b\n" "  bash scripts/setup.sh -u my-org -r my-project --clean-all -y"
  printf "%b\n" "  bash scripts/setup.sh -u my-org -r my-project -f -y"
  printf "%b\n" "  bash scripts/setup.sh -u my-org -r my-project --dry-run"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -u|--owner)
      NEW_OWNER="$2"
      shift 2
      ;;
    -r|--repo)
      NEW_REPO="$2"
      shift 2
      ;;
    -a|--author)
      NEW_AUTHOR="$2"
      shift 2
      ;;
    -e|--email)
      NEW_EMAIL="$2"
      shift 2
      ;;
    -f|--force)
      FORCE_SETUP=true
      shift
      ;;
    --clean|--self-destruct)
      CLEAN_AFTER_SETUP=true
      shift
      ;;
    --clean-all|--no-scripts)
      CLEAN_AFTER_SETUP=true
      CLEAN_ALL_SCRIPTS=true
      shift
      ;;
    -y|--yes)
      AUTO_CONFIRM=true
      shift
      ;;
    -n|--dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      log_error "未知参数: $1 (查看帮助请执行: bash scripts/setup.sh -h)"
      exit 1
      ;;
  esac
done

printf "\n%b\n" "${COLOR_BOLD}${COLOR_CYAN}================================================================${COLOR_RESET}"
printf "%b\n" "${COLOR_BOLD}${COLOR_CYAN}         OSS 模版项目一键初始化向导 (Template Setup Wizard)      ${COLOR_RESET}"
printf "%b\n" "${COLOR_BOLD}${COLOR_CYAN}================================================================${COLOR_RESET}"

if [ "$DRY_RUN" = true ]; then
  printf "%b\n\n" "${COLOR_BOLD}${COLOR_YELLOW}>>> 【演练模式 DRY-RUN 已激活】仅安全预览替换规划，不修改任何文件 <<<\n${COLOR_RESET}"
fi

# ==============================================================================
# 2. 定位仓库根目录与智能默认值推导
# ==============================================================================
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT=$(git rev-parse --show-toplevel)
else
  REPO_ROOT=$(pwd)
fi
cd "$REPO_ROOT"

# 防误触与自锁防御：检测当前仓库是否已被初始化过
IS_INITIALIZED=false
if [ -f "README.md" ] && ! grep -q "atengk/oss-template" "README.md" 2>/dev/null; then
  IS_INITIALIZED=true
fi

if [ "$IS_INITIALIZED" = true ] && [ "$FORCE_SETUP" = false ]; then
  log_info "检测到当前项目已完成初始化（README.md 中已无模版默认占位符）。"
  log_info "若需强制重新配置或覆盖更新，请追加 -f 或 --force 参数："
  log_info "  示例: bash scripts/setup.sh -f"
  log_info "向导已安全退出。"
  exit 0
fi

# 在 --force 强制覆盖或二次执行模式下，探测当前实际已写入的值供安全覆盖
CURR_OWNER=""
CURR_REPO=""
CURR_AUTHOR=""
CURR_EMAIL=""

if [ -f "SECURITY.md" ]; then
  if grep -q "github\.com/[^/]\+/[^/]\+/security/advisories" "SECURITY.md" 2>/dev/null; then
    PREV_SLUG=$(grep -oE "github\.com/[^/]+/[^/]+/security/advisories" "SECURITY.md" | head -n 1 | sed -e 's#github.com/##' -e 's#/security/advisories##')
    CURR_OWNER=$(echo "$PREV_SLUG" | cut -d'/' -f1)
    CURR_REPO=$(echo "$PREV_SLUG" | cut -d'/' -f2)
  fi
  if grep -q "安全联系邮箱" "SECURITY.md" 2>/dev/null; then
    CURR_EMAIL=$(grep -oE '`[^`]+@[^`]+`' "SECURITY.md" | head -n 1 | tr -d '`')
  fi
fi

if [ -f "LICENSE" ]; then
  if grep -q "Copyright [0-9]\+ " "LICENSE" 2>/dev/null; then
    CURR_AUTHOR=$(grep -oE "Copyright [0-9]+ [^(]+" "LICENSE" | head -n 1 | sed -e 's/Copyright [0-9]* //' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  fi
fi

DETECTED_REPO=$(basename "$REPO_ROOT")
if [ "$DETECTED_REPO" = "oss-template" ]; then
  DETECTED_REPO=""
elif [ -n "$CURR_REPO" ] && [ "$CURR_REPO" != "oss-template" ]; then
  DETECTED_REPO="$CURR_REPO"
fi

DETECTED_OWNER=""
REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null || echo "")
if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
  REMOTE_OWNER="${BASH_REMATCH[1]}"
  REMOTE_NAME="${BASH_REMATCH[2]}"
  if [ "$REMOTE_OWNER" != "atengk" ]; then
    DETECTED_OWNER="$REMOTE_OWNER"
  fi
  if [ -z "$DETECTED_REPO" ] && [ "$REMOTE_NAME" != "oss-template" ]; then
    DETECTED_REPO="$REMOTE_NAME"
  fi
fi
if [ -z "$DETECTED_OWNER" ] && [ -n "$CURR_OWNER" ] && [ "$CURR_OWNER" != "atengk" ]; then
  DETECTED_OWNER="$CURR_OWNER"
fi

DETECTED_AUTHOR=$(git config --get user.name 2>/dev/null || echo "")
if [ "$DETECTED_AUTHOR" = "Ateng" ]; then
  DETECTED_AUTHOR=""
fi
if [ -z "$DETECTED_AUTHOR" ] && [ -n "$CURR_AUTHOR" ] && [ "$CURR_AUTHOR" != "Ateng" ]; then
  DETECTED_AUTHOR="$CURR_AUTHOR"
fi

DETECTED_EMAIL=$(git config --get user.email 2>/dev/null || echo "")
if [ "$DETECTED_EMAIL" = "security@example.com" ]; then
  DETECTED_EMAIL=""
fi
if [ -z "$DETECTED_EMAIL" ] && [ -n "$CURR_EMAIL" ] && [ "$CURR_EMAIL" != "security@example.com" ]; then
  DETECTED_EMAIL="$CURR_EMAIL"
fi

# ==============================================================================
# 3. 收集并校验目标参数
# ==============================================================================
if [ "$AUTO_CONFIRM" = true ] || [ ! -t 0 ]; then
  # 静默 / 非交互模式：必须提供 -u 与 -r 参数，未传 -a 时缺省为 -u，未传 -e 时缺省为 DETECTED_EMAIL 或占位符
  if [ -z "$NEW_OWNER" ] || [ -z "$NEW_REPO" ]; then
    log_error "静默/非交互式模式下必须显式提供 -u/--owner 与 -r/--repo 参数！"
    log_error "示例: bash scripts/setup.sh -u my-org -r my-tool -a \"My Name\" -y"
    exit 1
  fi
  if [ -z "$NEW_AUTHOR" ]; then
    NEW_AUTHOR="$NEW_OWNER"
  fi
  if [ -z "$NEW_EMAIL" ]; then
    NEW_EMAIL="${DETECTED_EMAIL:-security@${NEW_OWNER}.com}"
  fi
else
  # 交互模式引导输入
  printf "\n%b请依次输入你的项目信息 (直接回车保留推荐默认值):%b\n\n" "${COLOR_BOLD}" "${COLOR_RESET}"

  # 输入 Owner
  if [ -z "$NEW_OWNER" ]; then
    DEFAULT_OWNER="${DETECTED_OWNER:-your-username}"
    printf "1. GitHub 用户名或组织名 [%b%s%b]: " "${COLOR_CYAN}" "$DEFAULT_OWNER" "${COLOR_RESET}"
    read -r INPUT_OWNER
    INPUT_OWNER=$(echo "$INPUT_OWNER" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    NEW_OWNER="${INPUT_OWNER:-$DEFAULT_OWNER}"
  fi

  # 输入 Repo
  if [ -z "$NEW_REPO" ]; then
    DEFAULT_REPO="${DETECTED_REPO:-your-repo}"
    printf "2. 新项目仓库名称 [%b%s%b]: " "${COLOR_CYAN}" "$DEFAULT_REPO" "${COLOR_RESET}"
    read -r INPUT_REPO
    INPUT_REPO=$(echo "$INPUT_REPO" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    NEW_REPO="${INPUT_REPO:-$DEFAULT_REPO}"
  fi

  # 输入 Author
  if [ -z "$NEW_AUTHOR" ]; then
    DEFAULT_AUTHOR="${DETECTED_AUTHOR:-$NEW_OWNER}"
    printf "3. 作者称谓 / 版权所有者 [%b%s%b]: " "${COLOR_CYAN}" "$DEFAULT_AUTHOR" "${COLOR_RESET}"
    read -r INPUT_AUTHOR
    INPUT_AUTHOR=$(echo "$INPUT_AUTHOR" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    NEW_AUTHOR="${INPUT_AUTHOR:-$DEFAULT_AUTHOR}"
  fi

  # 输入 Security Email
  if [ -z "$NEW_EMAIL" ]; then
    DEFAULT_EMAIL="${DETECTED_EMAIL:-security@${NEW_OWNER}.com}"
    printf "4. 安全漏洞披露邮箱 (SECURITY.md) [%b%s%b]: " "${COLOR_CYAN}" "$DEFAULT_EMAIL" "${COLOR_RESET}"
    read -r INPUT_EMAIL
    INPUT_EMAIL=$(echo "$INPUT_EMAIL" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    NEW_EMAIL="${INPUT_EMAIL:-$DEFAULT_EMAIL}"
  fi
fi

# 格式校验 (允许字母、数字、连字符、下划线和点)
VALID_NAME_REGEX="^[a-zA-Z0-9._-]+$"
if ! echo "$NEW_OWNER" | grep -Eq "$VALID_NAME_REGEX"; then
  log_error "无效的 GitHub 用户名/组织名: [$NEW_OWNER] (仅允许字母、数字、短横线、下划线或点)"
  exit 1
fi

if ! echo "$NEW_REPO" | grep -Eq "$VALID_NAME_REGEX"; then
  log_error "无效的仓库名称: [$NEW_REPO] (仅允许字母、数字、短横线、下划线或点)"
  exit 1
fi

if [ -z "$NEW_AUTHOR" ]; then
  NEW_AUTHOR="$NEW_OWNER"
fi

if [ -z "$NEW_EMAIL" ]; then
  NEW_EMAIL="security@${NEW_OWNER}.com"
fi

# ==============================================================================
# 4. 替换计划预览与确认
# ==============================================================================
printf "\n%b\n" "${COLOR_BOLD}${COLOR_CYAN}----------------------- 模版初始化替换规划 -----------------------${COLOR_RESET}"
printf "  1. 仓库全路径 : %b%s%b  ==>  %b%s/%s%b\n" "${COLOR_YELLOW}" "atengk/oss-template" "${COLOR_RESET}" "${COLOR_GREEN}" "$NEW_OWNER" "$NEW_REPO" "${COLOR_RESET}"
printf "  2. 组织 / 用户: %b%s%b  ==>  %b%s%b\n" "${COLOR_YELLOW}" "atengk" "${COLOR_RESET}" "${COLOR_GREEN}" "$NEW_OWNER" "${COLOR_RESET}"
printf "  3. 仓库名称   : %b%s%b  ==>  %b%s%b\n" "${COLOR_YELLOW}" "oss-template" "${COLOR_RESET}" "${COLOR_GREEN}" "$NEW_REPO" "${COLOR_RESET}"
printf "  4. 作者称谓   : %b%s%b  ==>  %b%s%b\n" "${COLOR_YELLOW}" "Ateng" "${COLOR_RESET}" "${COLOR_GREEN}" "$NEW_AUTHOR" "${COLOR_RESET}"
printf "  5. 安全邮箱   : %b%s%b  ==>  %b%s%b\n" "${COLOR_YELLOW}" "security@example.com" "${COLOR_RESET}" "${COLOR_GREEN}" "$NEW_EMAIL" "${COLOR_RESET}"
printf "  6. Git 钩子   : 自动配置核心钩子路径为 %b.githooks%b (守门 Conventional Commits)\n" "${COLOR_GREEN}" "${COLOR_RESET}"
if [ "$CLEAN_AFTER_SETUP" = true ]; then
  printf "  7. 自毁清理   : %b初始化完成后自动裁剪 README 模版教学章节、删除 setup.sh 并创建初始提交%b\n" "${COLOR_YELLOW}" "${COLOR_RESET}"
fi
printf "  8. 涉及文件   : README.md, CODE_OF_CONDUCT.md, CONTRIBUTING.md, SECURITY.md, LICENSE, scripts/*.sh, .githooks/...\n"
printf "%b\n\n" "${COLOR_BOLD}${COLOR_CYAN}------------------------------------------------------------------${COLOR_RESET}"

if [ "$DRY_RUN" = true ]; then
  log_success "[DRY-RUN] 演练完成！所有输入参数校验通过，未对仓库文件产生任何修改。"
  exit 0
fi

if [ "$AUTO_CONFIRM" = true ] || [ ! -t 0 ]; then
  log_info "已指定 -y 或处于非交互环境，跳过确认，开始执行替换。"
else
  printf "%b确认立即执行上述模版替换? [Y/n]: %b" "${COLOR_BOLD}" "${COLOR_RESET}"
  read -r CONFIRM
  CONFIRM=$(echo "$CONFIRM" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  case "$CONFIRM" in
    [nN][oO]|[nN])
      log_warn "初始化操作已取消，未做任何修改。"
      exit 0
      ;;
    *)
      ;;
  esac
fi

# ==============================================================================
# 5. 执行跨平台安全原地替换
# ==============================================================================
# 跨平台原地替换辅助函数 (通过临时文件写入并 mv 覆盖，完美兼容 macOS / Linux / Windows Git Bash)
safe_replace() {
  local target_file="$1"
  local search_str="$2"
  local replace_str="$3"

  if [ ! -f "$target_file" ]; then
    return 0
  fi

  # 对替换字符中的反斜杠、斜杠、& 以及 # 进行转义防御
  local escaped_replace
  escaped_replace=$(printf '%s' "$replace_str" | sed -e 's/[\\/&#]/\\&/g')

  local tmp_file="${target_file}.tmp.$$"
  sed "s#${search_str}#${escaped_replace}#g" "$target_file" > "$tmp_file"
  mv "$tmp_file" "$target_file"
}

# 自动裁剪 README.md 中的模版教学章节并注入标准业务快速开始骨架
replace_template_section_in_readme() {
  local readme_file="$REPO_ROOT/README.md"
  if [ ! -f "$readme_file" ]; then
    return 0
  fi
  if ! grep -q "<!-- TEMPLATE_SETUP_START -->" "$readme_file" 2>/dev/null; then
    return 0
  fi

  log_info "正在将 README.md 中的模版教学章节裁剪为标准业务快速开始骨架..."

  local tmp_file="${readme_file}.tmp.$$"
  local skeleton_file="${readme_file}.skel.$$"

  cat << 'EOF' > "$skeleton_file"
## 🛠️ 快速开始

### 1. 环境准备
请确保本地已就绪项目所需的运行环境与开发工具。

### 2. 本地构建与规范提交
```bash
# 激活本地 Git 规范提交守护钩子 (Conventional Commits 守门)
git config core.hooksPath .githooks

# 根据你的具体技术栈执行构建或测试 (请在此补充业务构建命令)
```

### 3. 配置 CI/CD 构建插槽
打开 [`.github/workflows/ci.yml`](./.github/workflows/ci.yml)，解除对应技术栈（Node.js / Java / Go / Python）步骤的注释即可激活自动化流水线。
EOF

  awk '
    BEGIN { inside=0 }
    /<!-- TEMPLATE_SETUP_START -->/ {
      inside=1
      while ((getline line < skeleton) > 0) {
        print line
      }
      close(skeleton)
      next
    }
    /<!-- TEMPLATE_SETUP_END -->/ {
      inside=0
      next
    }
    inside==0 { print }
  ' skeleton="$skeleton_file" "$readme_file" > "$tmp_file"

  rm -f "$skeleton_file"
  mv "$tmp_file" "$readme_file"
  log_success "已完成 README.md 模版教学章节自动裁剪与业务骨架注入！"
}

TARGET_FILES=(
  "README.md"
  "CODE_OF_CONDUCT.md"
  "CONTRIBUTING.md"
  "SECURITY.md"
  "LICENSE"
  ".cliff.toml"
  ".githooks/commit-msg"
  "scripts/commit.sh"
  "scripts/release.sh"
  "scripts/setup.sh"
  ".github/ISSUE_TEMPLATE/config.yml"
)

log_info "正在替换目标工程文件占位符..."

for file in "${TARGET_FILES[@]}"; do
  if [ -f "$file" ]; then
    # 按照先后顺序替换：先替换复合路径与邮箱，再替换独立单词
    safe_replace "$file" "atengk/oss-template" "${NEW_OWNER}/${NEW_REPO}"
    if [ -n "$CURR_OWNER" ] && [ -n "$CURR_REPO" ]; then
      safe_replace "$file" "${CURR_OWNER}/${CURR_REPO}" "${NEW_OWNER}/${NEW_REPO}"
    fi

    safe_replace "$file" "atengk" "${NEW_OWNER}"
    if [ -n "$CURR_OWNER" ]; then
      safe_replace "$file" "${CURR_OWNER}" "${NEW_OWNER}"
    fi

    safe_replace "$file" "oss-template" "${NEW_REPO}"
    if [ -n "$CURR_REPO" ]; then
      safe_replace "$file" "${CURR_REPO}" "${NEW_REPO}"
    fi

    safe_replace "$file" "Ateng" "${NEW_AUTHOR}"
    if [ -n "$CURR_AUTHOR" ]; then
      safe_replace "$file" "${CURR_AUTHOR}" "${NEW_AUTHOR}"
    fi

    safe_replace "$file" "security@example.com" "${NEW_EMAIL}"
    if [ -n "$CURR_EMAIL" ]; then
      safe_replace "$file" "${CURR_EMAIL}" "${NEW_EMAIL}"
    fi
    log_success "已完成更新: $file"
  fi
done

# ==============================================================================
# 6. 配置 Git 原生钩子 (core.hooksPath)
# ==============================================================================
if [ -d ".githooks" ]; then
  log_info "正在配置 Git 原生提交规范钩子 (.githooks)..."
  chmod +x .githooks/* 2>/dev/null || true
  git config core.hooksPath .githooks
  log_success "已激活 Git 本地提交守门钩子 (core.hooksPath = .githooks)"
fi

# ==============================================================================
# 7. 自毁清理与后续引导
# ==============================================================================
printf "\n%b\n" "${COLOR_BOLD}${COLOR_GREEN}================================================================${COLOR_RESET}"
printf "%b\n" "${COLOR_BOLD}${COLOR_GREEN}               🎉 模版初始化占位符替换圆满完成！                ${COLOR_RESET}"
printf "%b\n" "${COLOR_BOLD}${COLOR_GREEN}================================================================${COLOR_RESET}"

# 交互模式下询问是否自清理（若命令行未传 --clean 或 --clean-all）
if [ "$CLEAN_AFTER_SETUP" = false ] && [ -t 0 ] && [ "$AUTO_CONFIRM" = false ]; then
  printf "\n%b是否清理模版向导与脚本?%b\n" "${COLOR_BOLD}" "${COLOR_RESET}"
  printf "  %b1)%b 裁剪 README 并删除 setup.sh (保留日常提交与发版助手 commit.sh / release.sh)\n" "${COLOR_CYAN}" "${COLOR_RESET}"
  printf "  %b2)%b 纯原生零脚本模式 (裁剪 README 并彻底删除整个 scripts/ 目录)\n" "${COLOR_CYAN}" "${COLOR_RESET}"
  printf "  %b0)%b 保留所有脚本与模版教学，稍后手动处理 [默认]\n\n" "${COLOR_YELLOW}" "${COLOR_RESET}"
  printf "请输入选项 [0-2]: "
  read -r CLEAN_PROMPT
  CLEAN_PROMPT=$(echo "$CLEAN_PROMPT" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  case "$CLEAN_PROMPT" in
    1|[yY]|[yY][eE][sS])
      CLEAN_AFTER_SETUP=true
      CLEAN_ALL_SCRIPTS=false
      ;;
    2)
      CLEAN_AFTER_SETUP=true
      CLEAN_ALL_SCRIPTS=true
      ;;
    *)
      CLEAN_AFTER_SETUP=false
      ;;
  esac
fi

if [ "$CLEAN_AFTER_SETUP" = true ]; then
  if [ "$CLEAN_ALL_SCRIPTS" = true ]; then
    log_info "正在执行纯原生零脚本模式清理 (彻底删除 scripts/ 目录并裁剪 README)..."
    replace_template_section_in_readme
    rm -rf "$REPO_ROOT/scripts"
    git add -A
    git commit -m "chore: initialize repository from template (pure git zero-script mode)"
    log_success "已安全裁剪 README.md 并彻底删除 scripts/ 目录完成初始提交！"
  else
    log_info "正在裁剪模版教学章节并清理初始化向导..."
    replace_template_section_in_readme
    rm -f "$REPO_ROOT/scripts/setup.sh"
    git add -A
    git commit -m "chore: initialize repository from template"
    log_success "已安全裁剪 README.md、删除 scripts/setup.sh 并自动完成初始化提交！"
  fi
  printf "\n仓库现已整洁就绪。推荐后续操作:\n"
  printf "  1. 打开 %bREADME.md%b 补充完善你的业务功能介绍与安装步骤；\n" "${COLOR_CYAN}" "${COLOR_RESET}"
  printf "  2. 打开 %b.github/workflows/ci.yml%b 配置你的业务构建与测试步骤；\n" "${COLOR_CYAN}" "${COLOR_RESET}"
  printf "  3. 运行 %bgit push origin main%b 推送你的新项目。\n\n" "${COLOR_CYAN}" "${COLOR_RESET}"
else
  printf "\n推荐后续操作:\n"
  printf "  1. 运行 %bgit diff%b 查看具体变更细节；\n" "${COLOR_CYAN}" "${COLOR_RESET}"
  printf "  2. 参照 %bREADME.md%b 中的 <!-- TEMPLATE_SETUP_START --> 锚点，将模版教学更新为你自己的业务说明；\n" "${COLOR_CYAN}" "${COLOR_RESET}"
  printf "  3. 打开 %b.github/workflows/ci.yml%b 配置你的业务构建与测试步骤；\n" "${COLOR_CYAN}" "${COLOR_RESET}"
  printf "  4. 运行 %bbash scripts/commit.sh%b 提交你的项目初始化改动（或手动删除 scripts/setup.sh）。\n\n" "${COLOR_CYAN}" "${COLOR_RESET}"
fi
