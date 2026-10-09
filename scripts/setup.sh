#!/usr/bin/env bash
# ==============================================================================
# 模版初始化向导 (Template Initialization Setup Script)
#
# 一键替换模版中的组织名、仓库名、作者称谓等默认占位符，支持交互式与非交互式/AI自动化调用。
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
AUTO_CONFIRM=false
DRY_RUN=false

show_help() {
  printf "%b\n" "用法: bash scripts/setup.sh [选项]"
  printf "%b\n" ""
  printf "%b\n" "选项说明 (支持交互向导与非交互式/AI自动化调用):"
  printf "%b\n" "  -u, --owner <owner>     GitHub 用户名或组织名 (例如 my-org)"
  printf "%b\n" "  -r, --repo <repo>       仓库/项目名称 (例如 my-awesome-tool)"
  printf "%b\n" "  -a, --author <author>   作者称谓或版权所有者 (例如 Zhang San)"
  printf "%b\n" "  -y, --yes               跳过确认提示，直接执行替换"
  printf "%b\n" "  -n, --dry-run           演练模式，仅预览拟替换内容，不修改任何文件"
  printf "%b\n" "  -h, --help              显示帮助信息"
  printf "%b\n" ""
  printf "%b\n" "无参数运行示例 (交互向导模式):"
  printf "%b\n" "  bash scripts/setup.sh"
  printf "%b\n" ""
  printf "%b\n" "非交互式调用示例 (AI / 自动化执行):"
  printf "%b\n" "  bash scripts/setup.sh -u my-org -r my-project -a \"Zhang San\" -y"
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

DETECTED_REPO=$(basename "$REPO_ROOT")
if [ "$DETECTED_REPO" = "oss-template" ]; then
  DETECTED_REPO=""
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

DETECTED_AUTHOR=$(git config --get user.name 2>/dev/null || echo "")
if [ "$DETECTED_AUTHOR" = "Ateng" ]; then
  DETECTED_AUTHOR=""
fi

# ==============================================================================
# 3. 收集并校验目标参数
# ==============================================================================
if [ "$AUTO_CONFIRM" = true ] || [ ! -t 0 ]; then
  # 静默 / 非交互模式：必须提供 -u 与 -r 参数，未传 -a 时自动缺省为 -u
  if [ -z "$NEW_OWNER" ] || [ -z "$NEW_REPO" ]; then
    log_error "静默/非交互式模式下必须显式提供 -u/--owner 与 -r/--repo 参数！"
    log_error "示例: bash scripts/setup.sh -u my-org -r my-tool -a \"My Name\" -y"
    exit 1
  fi
  if [ -z "$NEW_AUTHOR" ]; then
    NEW_AUTHOR="$NEW_OWNER"
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

# ==============================================================================
# 4. 替换计划预览与确认
# ==============================================================================
printf "\n%b\n" "${COLOR_BOLD}${COLOR_CYAN}----------------------- 模版初始化替换规划 -----------------------${COLOR_RESET}"
printf "  1. 仓库全路径 : %b%s%b  ==>  %b%s/%s%b\n" "${COLOR_YELLOW}" "atengk/oss-template" "${COLOR_RESET}" "${COLOR_GREEN}" "$NEW_OWNER" "$NEW_REPO" "${COLOR_RESET}"
printf "  2. 组织 / 用户: %b%s%b  ==>  %b%s%b\n" "${COLOR_YELLOW}" "atengk" "${COLOR_RESET}" "${COLOR_GREEN}" "$NEW_OWNER" "${COLOR_RESET}"
printf "  3. 仓库名称   : %b%s%b  ==>  %b%s%b\n" "${COLOR_YELLOW}" "oss-template" "${COLOR_RESET}" "${COLOR_GREEN}" "$NEW_REPO" "${COLOR_RESET}"
printf "  4. 作者称谓   : %b%s%b  ==>  %b%s%b\n" "${COLOR_YELLOW}" "Ateng" "${COLOR_RESET}" "${COLOR_GREEN}" "$NEW_AUTHOR" "${COLOR_RESET}"
printf "  5. 涉及文件   : README.md, CONTRIBUTING.md, SECURITY.md, LICENSE, scripts/*.sh, .github/...\n"
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

TARGET_FILES=(
  "README.md"
  "CONTRIBUTING.md"
  "SECURITY.md"
  "LICENSE"
  "scripts/commit.sh"
  "scripts/release.sh"
  "scripts/setup.sh"
  ".github/ISSUE_TEMPLATE/config.yml"
)

log_info "正在替换目标工程文件占位符..."

for file in "${TARGET_FILES[@]}"; do
  if [ -f "$file" ]; then
    # 按照先后顺序替换：先替换复合路径，再替换独立单词
    safe_replace "$file" "atengk/oss-template" "${NEW_OWNER}/${NEW_REPO}"
    safe_replace "$file" "atengk" "${NEW_OWNER}"
    safe_replace "$file" "oss-template" "${NEW_REPO}"
    safe_replace "$file" "Ateng" "${NEW_AUTHOR}"
    log_success "已完成更新: $file"
  fi
done

printf "\n%b\n" "${COLOR_BOLD}${COLOR_GREEN}================================================================${COLOR_RESET}"
printf "%b\n" "${COLOR_BOLD}${COLOR_GREEN}               🎉 模版初始化占位符替换圆满完成！                ${COLOR_RESET}"
printf "%b\n" "${COLOR_BOLD}${COLOR_GREEN}================================================================${COLOR_RESET}"
printf "\n推荐后续操作:\n"
printf "  1. 运行 %bgit diff%b 查看具体变更细节；\n" "${COLOR_CYAN}" "${COLOR_RESET}"
printf "  2. 打开 %b.github/workflows/ci.yml%b 配置你的业务构建与测试步骤；\n" "${COLOR_CYAN}" "${COLOR_RESET}"
printf "  3. 运行 %bbash scripts/commit.sh%b 提交你的项目初始化改动。\n\n" "${COLOR_CYAN}" "${COLOR_RESET}"
