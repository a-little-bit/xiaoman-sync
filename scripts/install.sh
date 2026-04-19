#!/bin/bash
# install.sh - 小满同步系统一键安装脚本
# 用法:
#   ./install.sh          # 安装 crontab 定时任务
#   ./install.sh --uninstall  # 卸载定时任务
#   ./install.sh --status     # 查看当前安装状态

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

ACTION="install"
[ "${1:-}" = "--uninstall" ] && ACTION="uninstall"
[ "${1:-}" = "--status" ] && ACTION="status"

CRON_TAG="# xiaoman-sync"
CRON_CMD="*/5 * * * * ${SCRIPT_DIR}/sync_daemon.sh --once >> ${LOG_FILE} 2>&1 ${CRON_TAG}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# === 前置检查 ===
preflight() {
    # 检查 jq
    if ! command -v jq &>/dev/null; then
        warn "jq 未安装（check_tasks.sh 需要），建议安装: apt install jq 或 yum install jq"
    fi

    # 检查 git
    if ! command -v git &>/dev/null; then
        error "git 未安装，请先安装 git"
        exit 1
    fi

    # 检查仓库路径
    if [ ! -d "${REPO_PATH}" ]; then
        error "仓库路径不存在: ${REPO_PATH}"
        exit 1
    fi

    # 创建日志目录
    mkdir -p "${LOG_DIR}" 2>/dev/null || true

    # 设置脚本执行权限
    for script in config.sh sync_daemon.sh check_tasks.sh complete_task.sh notify.sh; do
        local target="${SCRIPT_DIR}/${script}"
        if [ -f "${target}" ]; then
            chmod +x "${target}"
        fi
    done

    info "前置检查完成"
}

# === 安装 crontab ===
install_crontab() {
    preflight

    # 检查是否已安装
    if crontab -l 2>/dev/null | grep -q "${CRON_TAG}"; then
        warn "定时任务已存在，如需更新请先卸载再安装"
        return 0
    fi

    # 添加 crontab 条目
    (crontab -l 2>/dev/null; echo "${CRON_CMD}") | crontab -
    info "✅ crontab 定时任务已安装"
    info "   同步频率: 每5分钟"
    info "   日志位置: ${LOG_FILE}"
    info ""
    info "可用命令："
    info "  手动同步: ${SCRIPT_DIR}/sync_daemon.sh --once"
    info "  查看定时: crontab -l | grep xiaoman-sync"
    info "  卸载:     ${SCRIPT_DIR}/install.sh --uninstall"
}

# === 卸载 crontab ===
uninstall_crontab() {
    if ! crontab -l 2>/dev/null | grep -q "${CRON_TAG}"; then
        warn "定时任务未安装，无需卸载"
        return 0
    fi

    crontab -l 2>/dev/null | grep -v "${CRON_TAG}" | crontab -
    info "✅ crontab 定时任务已卸载"
}

# === 查看状态 ===
show_status() {
    echo ""
    echo "=== 小满同步系统状态 ==="
    echo ""

    # crontab 状态
    if crontab -l 2>/dev/null | grep -q "${CRON_TAG}"; then
        echo "  crontab 定时任务: ✅ 已安装"
        crontab -l 2>/dev/null | grep "${CRON_TAG}" | sed 's/^/    /'
    else
        echo "  crontab 定时任务: ❌ 未安装"
    fi

    echo ""
    echo "  仓库路径: ${REPO_PATH}"
    echo "  同步间隔: ${SYNC_INTERVAL} 秒"
    echo "  通知方式: ${NOTIFY_MODE}"
    echo "  日志路径: ${LOG_FILE}"
    echo ""

    # 检查关键文件
    echo "  --- 文件检查 ---"
    [ -f "${TASKS_FILE}" ]       && echo "  任务文件:     ✅" || echo "  任务文件:     ❌"
    [ -f "${STATUS_FILE}" ]      && echo "  状态文件:     ✅" || echo "  状态文件:     ❌"
    [ -f "${RESULTS_FILE}" ]     && echo "  结果文件:     ✅" || echo "  结果文件:     ❌"
    [ -f "${ORIGINALS_FILE}" ]   && echo "  原始记录:     ✅" || echo "  原始记录:     ❌"
    [ -f "${TASKS_READ_FILE}" ]  && echo "  已读标记:     ✅" || echo "  已读标记:     ⚠️  不存在（首次运行后创建）"

    echo ""

    # 检查脚本权限
    echo "  --- 脚本权限 ---"
    for script in sync_daemon.sh check_tasks.sh complete_task.sh notify.sh; do
        local target="${SCRIPT_DIR}/${script}"
        if [ -f "${target}" ]; then
            if [ -x "${target}" ]; then
                echo "  ${script}: ✅ 可执行"
            else
                echo "  ${script}: ❌ 不可执行（chmod +x 修复）"
            fi
        else
            echo "  ${script}: ❌ 不存在"
        fi
    done

    echo ""
}

# === 入口 ===
case "${ACTION}" in
    install)
        install_crontab
        ;;
    uninstall)
        uninstall_crontab
        ;;
    status)
        show_status
        ;;
    *)
        echo "用法: $0 [--install|--uninstall|--status]"
        exit 1
        ;;
esac
