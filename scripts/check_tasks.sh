#!/bin/bash
# check_tasks.sh - 任务检测脚本
# 用法: ./check_tasks.sh [--dry-run]
#
# 读取 tasks.jsonl，对比 .tasks_read 标记文件，
# 输出新任务列表（JSON 格式），并更新标记文件。
#
# 退出码: 0=有新任务, 1=无新任务, 2=错误

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

DRY_RUN_FLAG=false
[ "${1:-}" = "--dry-run" ] && DRY_RUN_FLAG=true
[ "${DRY_RUN}" = "true" ] && DRY_RUN_FLAG=true

# 日志函数
log() {
    local ts
    ts="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[${ts}] [check_tasks] $*" >> "${LOG_FILE}" 2>/dev/null || true
}

mkdir -p "${LOG_DIR}" 2>/dev/null || true

# === 验证输入文件 ===
if [ ! -f "${TASKS_FILE}" ]; then
    log "错误: 任务文件不存在: ${TASKS_FILE}"
    echo '{"error":"任务文件不存在"}'
    exit 2
fi

# === 读取已读任务ID ===
declare -A READ_IDS
if [ -f "${TASKS_READ_FILE}" ]; then
    while IFS= read -r line; do
        [ -z "${line}" ] && continue
        READ_IDS["${line}"]=1
    done < "${TASKS_READ_FILE}"
    log "已加载标记文件，共 ${#READ_IDS[@]} 个已读任务"
else
    log "标记文件不存在，将首次扫描所有任务"
fi

# === 扫描新任务 ===
NEW_TASKS_JSON="["
NEW_IDS=()
FIRST=true

while IFS= read -r line; do
    [ -z "${line}" ] && continue

    # 提取任务ID
    task_id=$(echo "${line}" | jq -r '.id // empty' 2>/dev/null)
    [ -z "${task_id}" ] && continue

    # 跳过已读任务
    if [ "${READ_IDS[${task_id}]+_}" ]; then
        continue
    fi

    # 提取任务信息
    title=$(echo "${line}" | jq -r '.title // "无标题"' 2>/dev/null)
    priority=$(echo "${line}" | jq -r '.p // 3' 2>/dev/null)
    deadline=$(echo "${line}" | jq -r '.deadline // ""' 2>/dev/null)

    if [ "${FIRST}" = true ]; then
        FIRST=false
    else
        NEW_TASKS_JSON+=","
    fi

    NEW_TASKS_JSON+=$(cat <<EOF
{"id":"${task_id}","title":"${title}","priority":${priority},"deadline":"${deadline}"}
EOF
)
    NEW_IDS+=("${task_id}")
    log "发现新任务: ${task_id} - ${title}"
done < "${TASKS_FILE}"

NEW_TASKS_JSON+="]"

# === 输出结果 ===
COUNT=${#NEW_IDS[@]}

if [ "${COUNT}" -eq 0 ]; then
    OUTPUT='{"count":0,"tasks":[]}'
    log "无新任务"
    echo "${OUTPUT}"
    exit 1
fi

OUTPUT=$(jq -n --argjson count "${COUNT}" --argjson tasks "${NEW_TASKS_JSON}" \
    '{count: $count, tasks: $tasks}')
echo "${OUTPUT}"
log "共发现 ${COUNT} 个新任务"

# === 更新标记文件 ===
if [ "${DRY_RUN_FLAG}" = false ]; then
    mkdir -p "$(dirname "${TASKS_READ_FILE}")" 2>/dev/null || true
    for id in "${NEW_IDS[@]}"; do
        echo "${id}" >> "${TASKS_READ_FILE}"
    done
    log "标记文件已更新"
else
    log "[DRY-RUN] 跳过标记文件更新"
fi

exit 0
