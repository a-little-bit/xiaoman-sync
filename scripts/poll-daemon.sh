#!/bin/bash
# 零 Token 小满同步守护进程
# 纯 Shell 轮询 git 变更，仅在检测到新内容时才注入 systemEvent 唤醒惜影
# 这样大部分时候零消耗，只有真正有新消息时才花 token

SYNC_DIR="/workspace/projects/xiaoman-sync"
CHECK_SCRIPT="$SYNC_DIR/scripts/check-xiaoman.sh"
LOG_FILE="$SYNC_DIR/logs/poll.log"
INTERVAL=120  # 每 120 秒检查一次

mkdir -p "$SYNC_DIR/logs"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

log "=== 守护进程启动 ==="
log "检查间隔: ${INTERVAL}s"

while true; do
    # 执行检查（纯 shell，零 token）
    RESULT=$(bash "$CHECK_SCRIPT" 2>>"$LOG_FILE")
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -ne 0 ]; then
        # 有新内容！输出到日志
        log "检测到新内容: $RESULT"
        # 这里不需要主动唤醒，heartbeat 会处理
        # 或者通过写入文件让下次 heartbeat 发现
        echo "1" > "$SYNC_DIR/state/.has-new-content"
    else
        # 无新内容，静默
        :
    fi
    
    sleep $INTERVAL
done
