#!/bin/bash
# complete_task.sh - 任务完成脚本
# 用法: ./complete_task.sh <任务ID> <状态> <结果摘要> [产出文件列表]
#
# 参数:
#   任务ID        - 如 t001
#   状态          - done / failed / partial
#   结果摘要      - 完成描述
#   产出文件列表  - 逗号分隔（可选）
#
# 示例:
#   ./complete_task.sh t001 done "完成需求调研" "outputs/xiaolongxia/2026-04-19/t001_research/"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# === 参数校验 ===
if [ $# -lt 3 ]; then
    echo "用法: $0 <任务ID> <状态> <结果摘要> [产出文件列表]"
    echo "状态: done / failed / partial"
    exit 1
fi

TASK_ID="$1"
STATUS="$2"
SUMMARY="$3"
OUTPUTS="${4:-}"

# 验证状态值
case "${STATUS}" in
    done|failed|partial) ;;
    *)
        echo "错误: 无效状态 '${STATUS}'，应为 done/failed/partial"
        exit 1
        ;;
esac

# 日志函数
log() {
    local ts
    ts="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[${ts}] [complete_task] $*" >> "${LOG_FILE}" 2>/dev/null || true
}

mkdir -p "${LOG_DIR}" 2>/dev/null || true
mkdir -p "$(dirname "${RESULTS_FILE}")" 2>/dev/null || true
mkdir -p "$(dirname "${ORIGINALS_FILE}")" 2>/dev/null || true

TIMESTAMP="$(date '+%Y%m%dT%H%M')"

log "开始完成任务: ${TASK_ID} 状态=${STATUS}"

# === 验证 jq 可用 ===
if ! command -v jq &>/dev/null; then
    log "错误: jq 未安装"
    echo "错误: jq 未安装，请运行 apt install jq 或 yum install jq"
    exit 1
fi

# === 更新 state/status.json ===
if [ -f "${STATUS_FILE}" ]; then
    # 更新 working_on 为 null，completed_count +1
    TEMP_STATUS=$(mktemp)
    jq --arg task "${TASK_ID}" '
        if .working_on == $task then .working_on = null else . end |
        .xiaolongxia.last_result_id = $task |
        .xiaolongxia.completed_count = ((.xiaolongxia.completed_count // 0) + 1)
    ' "${STATUS_FILE}" > "${TEMP_STATUS}" && mv "${TEMP_STATUS}" "${STATUS_FILE}"
    log "状态文件已更新"
else
    log "警告: 状态文件不存在: ${STATUS_FILE}"
fi

# === 构建结果记录 ===
RESULT_JSON=$(jq -n \
    --arg id "${TASK_ID}" \
    --arg status "${STATUS}" \
    --arg message "${SUMMARY}" \
    --arg time "${TIMESTAMP}" \
    --arg outputs "${OUTPUTS}" \
    '{id: $id, status: $status, message: $message, time: $time, outputs: $outputs}')

# 计算简单哈希（用于原始记录）
HASH="sha256:$(echo "${RESULT_JSON}" | sha256sum | cut -d' ' -f1)"

# === 追加到 results.jsonl ===
echo "${RESULT_JSON}" >> "${RESULTS_FILE}"
log "结果已写入 ${RESULTS_FILE}"

# === 追加到 originals/results.jsonl ===
ORIGINAL_JSON=$(jq -n \
    --arg id "${TASK_ID}" \
    --arg status "${STATUS}" \
    --arg message "${SUMMARY}" \
    --arg time "${TIMESTAMP}" \
    --arg outputs "${OUTPUTS}" \
    --arg hash "${HASH}" \
    '{id: $id, status: $status, message: $message, time: $time, outputs: $outputs, hash: $hash}')
echo "${ORIGINAL_JSON}" >> "${ORIGINALS_FILE}"
log "原始记录已写入 ${ORIGINALS_FILE}"

# === Git 提交 ===
cd "${REPO_PATH}"
git add -A

if git diff --cached --quiet; then
    log "无变更需要提交"
else
    COMMIT_MSG="feat: ${TASK_ID} ${STATUS} - ${SUMMARY}"
    git commit -m "${COMMIT_MSG}"
    log "已提交: ${COMMIT_MSG}"

    # 推送到双端
    git push github "${BRANCH}" 2>/dev/null || log "推送到 GitHub 失败（稍后重试）"
    git push gitee "${BRANCH}" 2>/dev/null || log "推送到 Gitee 失败（稍后重试）"
    log "推送完成"
fi

# === 发送通知 ===
if [ "${STATUS}" = "done" ]; then
    "${SCRIPT_DIR}/notify.sh" "任务完成" "${TASK_ID}: ${SUMMARY}" 3
elif [ "${STATUS}" = "failed" ]; then
    "${SCRIPT_DIR}/notify.sh" "任务失败" "${TASK_ID}: ${SUMMARY}" 1
else
    "${SCRIPT_DIR}/notify.sh" "任务部分完成" "${TASK_ID}: ${SUMMARY}" 2
fi

log "任务 ${TASK_ID} 处理完成，状态: ${STATUS}"
echo "✅ 任务 ${TASK_ID} 已标记为 ${STATUS}，结果已记录并推送。"
