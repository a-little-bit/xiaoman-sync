#!/bin/bash
# config.sh - 小满同步系统配置文件
# 此文件被其他脚本 source 引用，不应直接执行

# === 仓库路径 ===
REPO_PATH="/workspace/projects/xiaoman-sync"

# === 同步配置 ===
SYNC_INTERVAL=300          # 同步间隔（秒），5分钟
SYNC_PULL_ORDER="github gitee"  # 拉取优先顺序

# === 路径配置 ===
TASKS_FILE="${REPO_PATH}/inbox/xiaoman/tasks.jsonl"
TASKS_READ_FILE="${REPO_PATH}/inbox/xiaolongxia/.tasks_read"
RESULTS_FILE="${REPO_PATH}/inbox/xiaolongxia/results.jsonl"
ORIGINALS_FILE="${REPO_PATH}/originals/results.jsonl"
STATUS_FILE="${REPO_PATH}/state/status.json"
NOTIFICATION_FILE="${REPO_PATH}/inbox/xiaolongxia/notifications.txt"
LOCK_FILE="/tmp/xiaoman-sync.lock"

# === 日志配置 ===
LOG_DIR="${REPO_PATH}/logs"
LOG_FILE="${LOG_DIR}/sync.log"
LOG_MAX_SIZE=10485760      # 日志最大10MB
LOG_MAX_FILES=5            # 保留最近5个日志文件

# === 通知配置 ===
# 通知方式：desktop / file / http / none（可多选，空格分隔）
NOTIFY_MODE="file"

# HTTP 通知地址（可选，仅 NOTIFY_MODE 包含 http 时生效）
NOTIFY_HTTP_URL=""

# === 行为配置 ===
AUTO_EXECUTE=false         # 是否自动执行任务（false=仅通知）
DRY_RUN=false              # dry-run 模式（只检测不执行）
BRANCH="main"              # Git 分支名
