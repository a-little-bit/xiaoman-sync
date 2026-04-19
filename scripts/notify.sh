#!/bin/bash
# notify.sh - 通知脚本
# 用法: ./notify.sh "标题" "内容" [优先级]
#
# 优先级: 1=高, 2=中, 3=低（可选，默认2）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

TITLE="${1:-通知}"
CONTENT="${2:-}"
PRIORITY="${3:-2}"

# 日志函数
log() {
    local ts
    ts="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[${ts}] [notify] $*" >> "${LOG_FILE}" 2>/dev/null || true
}

# 确保日志目录存在
mkdir -p "${LOG_DIR}" 2>/dev/null || true

# 优先级标签
case "${PRIORITY}" in
    1) PRIORITY_LABEL="🔴 高" ;;
    2) PRIORITY_LABEL="🟡 中" ;;
    3) PRIORITY_LABEL="🟢 低" ;;
    *) PRIORITY_LABEL="⚪ 未知" ;;
esac

TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
NOTICE="[${TIMESTAMP}] [${PRIORITY_LABEL}] ${TITLE} - ${CONTENT}"

# === 桌面通知 ===
notify_desktop() {
    if command -v notify-send &>/dev/null; then
        local urgency="normal"
        [ "${PRIORITY}" = "1" ] && urgency="critical"
        notify-send -u "${urgency}" "${TITLE}" "${CONTENT}" 2>/dev/null || true
        log "桌面通知已发送"
    else
        log "notify-send 不可用，跳过桌面通知"
    fi
}

# === 文件通知 ===
notify_file() {
    mkdir -p "$(dirname "${NOTIFICATION_FILE}")" 2>/dev/null || true
    echo "${NOTICE}" >> "${NOTIFICATION_FILE}"
    log "通知已写入 ${NOTIFICATION_FILE}"
}

# === HTTP 通知 ===
notify_http() {
    if [ -z "${NOTIFY_HTTP_URL}" ]; then
        log "NOTIFY_HTTP_URL 未配置，跳过 HTTP 通知"
        return 0
    fi
    local payload
    payload=$(cat <<EOF
{
    "title": $(echo "${TITLE}" | jq -Rs .),
    "content": $(echo "${CONTENT}" | jq -Rs .),
    "priority": ${PRIORITY},
    "timestamp": "${TIMESTAMP}"
}
EOF
    )
    # 使用 curl 发送，超时10秒
    if command -v curl &>/dev/null; then
        curl -s -m 10 -X POST \
            -H "Content-Type: application/json" \
            -d "${payload}" \
            "${NOTIFY_HTTP_URL}" 2>/dev/null || {
            log "HTTP 通知发送失败"
            return 1
        }
        log "HTTP 通知已发送到 ${NOTIFY_HTTP_URL}"
    elif command -v wget &>/dev/null; then
        wget -q -O- --timeout=10 --post-data="${payload}" \
            --header="Content-Type: application/json" \
            "${NOTIFY_HTTP_URL}" 2>/dev/null || {
            log "HTTP 通知发送失败"
            return 1
        }
        log "HTTP 通知已发送到 ${NOTIFY_HTTP_URL}"
    else
        log "curl/wget 均不可用，跳过 HTTP 通知"
    fi
}

# === 分发通知 ===
for mode in ${NOTIFY_MODE}; do
    case "${mode}" in
        desktop) notify_desktop ;;
        file)    notify_file ;;
        http)    notify_http ;;
        none)    log "通知模式为 none，跳过" ;;
        *)       log "未知通知模式: ${mode}，跳过" ;;
    esac
done

log "通知完成: ${TITLE}"
