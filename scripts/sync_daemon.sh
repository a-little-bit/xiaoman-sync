#!/bin/bash
# sync_daemon.sh - 主同步守护脚本
# 用法: ./sync_daemon.sh [--dry-run] [--once]
#
# --dry-run  只检测不执行写操作
# --once     只执行一次同步检查，不循环
#
# 正常用法由 crontab 或 install.sh 设置定时调用（--once 模式）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

MODE_ONCE=false
[ "${1:-}" = "--once" ] && MODE_ONCE=true
[ "${1:-}" = "--dry-run" ] && DRY_RUN=true
[ "${2:-}" = "--dry-run" ] && DRY_RUN=true

# 日志函数
log() {
    local ts
    ts="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[${ts}] [sync_daemon] $*" >> "${LOG_FILE}" 2>/dev/null || true
    # 同时输出到 stdout（crontab 会捕获）
    echo "[${ts}] $*"
}

mkdir -p "${LOG_DIR}" 2>/dev/null || true

# === 锁文件 ===
acquire_lock() {
    if [ -f "${LOCK_FILE}" ]; then
        local pid
        pid=$(cat "${LOCK_FILE}" 2>/dev/null)
        if [ -n "${pid}" ] && kill -0 "${pid}" 2>/dev/null; then
            log "另一个实例正在运行 (PID=${pid})，退出"
            exit 0
        else
            log "锁文件存在但进程 ${pid} 不存在，清除残留锁"
            rm -f "${LOCK_FILE}"
        fi
    fi
    echo $$ > "${LOCK_FILE}"
    trap 'rm -f "${LOCK_FILE}"' EXIT
}

release_lock() {
    rm -f "${LOCK_FILE}"
}

# === 日志轮转 ===
rotate_log() {
    if [ ! -f "${LOG_FILE}" ]; then
        return 0
    fi
    local size
    size=$(stat -f%z "${LOG_FILE}" 2>/dev/null || stat -c%s "${LOG_FILE}" 2>/dev/null || echo 0)
    if [ "${size}" -ge "${LOG_MAX_SIZE}" ]; then
        log "日志文件超过 ${LOG_MAX_SIZE} 字节，执行轮转"
        for i in $(seq $((LOG_MAX_FILES - 1)) -1 1); do
            [ -f "${LOG_FILE}.${i}" ] && mv "${LOG_FILE}.${i}" "${LOG_FILE}.$((i + 1))"
        done
        mv "${LOG_FILE}" "${LOG_FILE}.1"
        touch "${LOG_FILE}"
        # 删除超出数量的旧日志
        [ -f "${LOG_FILE}.$((LOG_MAX_FILES + 1))" ] && rm -f "${LOG_FILE}.$((LOG_MAX_FILES + 1))"
    fi
}

# === 同步拉取 ===
sync_pull() {
    cd "${REPO_PATH}"

    if [ "${DRY_RUN}" = true ]; then
        log "[DRY-RUN] 跳过 git pull"
        return 0
    fi

    log "开始拉取远程更新..."

    # stash 本地未提交修改以防冲突
    local has_stash=false
    if ! git diff --quiet || ! git diff --cached --quiet; then
        log "检测到本地修改，stash 暂存"
        git stash push -m "auto-sync-$(date +%Y%m%dT%H%M%S)" --quiet
        has_stash=true
    fi

    # 按优先顺序拉取
    local pull_success=false
    for remote in ${SYNC_PULL_ORDER}; do
        log "尝试从 ${remote} 拉取..."
        if git pull "${remote}" "${BRANCH}" --rebase 2>/dev/null; then
            log "从 ${remote} 拉取成功"
            pull_success=true
            break
        else
            log "从 ${remote} 拉取失败，尝试下一个"
        fi
    done

    # 恢复 stash
    if [ "${has_stash}" = true ]; then
        log "恢复 stash 暂存"
        git stash pop --quiet 2>/dev/null || {
            log "stash pop 冲突，保留暂存"
            git stash list | tail -1
        }
    fi

    if [ "${pull_success}" = false ]; then
        log "警告: 所有远程拉取均失败"
    fi
}

# === 推送本地提交 ===
sync_push() {
    cd "${REPO_PATH}"

    if [ "${DRY_RUN}" = true ]; then
        log "[DRY-RUN] 跳过 git push"
        return 0
    fi

    if git diff --cached --quiet && git diff --quiet; then
        return 0
    fi

    log "推送本地提交到双端..."
    for remote in github gitee; do
        if git push "${remote}" "${BRANCH}" 2>/dev/null; then
            log "推送到 ${remote} 成功"
        else
            log "推送到 ${remote} 失败"
        fi
    done
}

# === 检测新任务 ===
check_new_tasks() {
    log "检查新任务..."
    local result
    result=$("${SCRIPT_DIR}/check_tasks.sh" --dry-run 2>/dev/null) || {
        local exit_code=$?
        if [ "${exit_code}" -eq 1 ]; then
            log "无新任务"
            return 1
        else
            log "任务检测出错: exit_code=${exit_code}"
            return 2
        fi
    }

    # 实际检测（非 dry-run）
    result=$("${SCRIPT_DIR}/check_tasks.sh" 2>/dev/null) || {
        log "无新任务"
        return 1
    }

    local count
    count=$(echo "${result}" | jq -r '.count // 0')
    if [ "${count}" -eq 0 ]; then
        log "无新任务"
        return 1
    fi

    log "发现 ${count} 个新任务"
    echo "${result}"

    # 更新 status.json
    if [ -f "${STATUS_FILE}" ] && [ "${DRY_RUN}" = false ]; then
        local first_task_id
        first_task_id=$(echo "${result}" | jq -r '.tasks[0].id // empty')
        if [ -n "${first_task_id}" ]; then
            TEMP_STATUS=$(mktemp)
            jq --arg task "${first_task_id}" --argjson count "${count}" '
                .working_on = $task |
                .xiaoman.pending_count = $count |
                .last_sync = (now | strftime("%Y%m%dT%H%M"))
            ' "${STATUS_FILE}" > "${TEMP_STATUS}" && mv "${TEMP_STATUS}" "${STATUS_FILE}"
            log "状态文件已更新: working_on=${first_task_id}"
        fi
    fi

    return 0
}

# === 主循环 ===
main() {
    acquire_lock
    rotate_log
    log "========== 同步开始 =========="

    # 1. 拉取远程更新
    sync_pull

    # 2. 检测新任务
    local task_result
    if task_result=$(check_new_tasks); then
        # 有新任务 → 通知
        log "有新任务，发送通知..."
        local task_ids
        task_ids=$(echo "${task_result}" | jq -r '.tasks[].id' 2>/dev/null)
        local task_titles
        task_titles=$(echo "${task_result}" | jq -r '.tasks | map("\(.id): \(.title)") | join(", ")' 2>/dev/null)

        if [ "${DRY_RUN}" = false ]; then
            "${SCRIPT_DIR}/notify.sh" "📋 新任务到达" "${task_titles}" 2
        fi

        # 如果启用自动执行
        if [ "${AUTO_EXECUTE}" = true ] && [ "${DRY_RUN}" = false ]; then
            log "自动执行模式已启用"
            # TODO: 接入自动执行逻辑
        fi
    fi

    # 3. 推送本地变更
    sync_push

    log "========== 同步完成 =========="
    release_lock
}

# === 入口 ===
if [ "${MODE_ONCE}" = true ]; then
    main
else
    log "守护模式启动，间隔 ${SYNC_INTERVAL} 秒"
    while true; do
        main
        sleep "${SYNC_INTERVAL}"
    done
fi
