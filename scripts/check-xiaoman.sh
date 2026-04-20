#!/bin/bash
# 小满同步检查脚本 — 纯 Shell，零 LLM Token 消耗
# 用法: bash /workspace/projects/xiaoman-sync/scripts/check-xiaoman.sh
# 返回值: 0=无新内容, 1=有新内容需要处理

SYNC_DIR="/workspace/projects/xiaoman-sync"
STATE_FILE="/workspace/projects/xiaoman-sync/state/xiying-poll-state.json"
INBOX_DIR="$SYNC_DIR/inbox/xiaoman"
URGENT_DIR="$SYNC_DIR/urgent"
RESULTS_FILE="$SYNC_DIR/inbox/xiaolongxia/results.jsonl"

# 初始化状态文件
if [ ! -f "$STATE_FILE" ]; then
    echo '{"lastCommit":"","lastUrgentCheck":""}' > "$STATE_FILE"
fi

cd "$SYNC_DIR" || exit 1

# 拉取双端
PULL_OUTPUT=$(git pull gitee main 2>&1 && git pull github main 2>&1)

# 获取最新 commit hash
CURRENT_COMMIT=$(git rev-parse --short HEAD)
LAST_COMMIT=$(python3 -c "import json; print(json.load(open('$STATE_FILE')).get('lastCommit',''))" 2>/dev/null)

# 检查是否有新内容
HAS_NEW=0
NEW_FILES=""

if [ "$CURRENT_COMMIT" != "$LAST_COMMIT" ]; then
    # 有新 commit，检查新增文件
    if [ "$LAST_COMMIT" != "" ]; then
        NEW_FILES=$(git diff --name-only "$LAST_COMMIT" "$CURRENT_COMMIT" -- "$INBOX_DIR/" "$URGENT_DIR/" 2>/dev/null)
    else
        # 首次运行
        NEW_FILES=$(find "$INBOX_DIR" "$URGENT_DIR" -name "*.md" -o -name "*.jsonl" 2>/dev/null)
    fi
    
    if [ -n "$NEW_FILES" ]; then
        HAS_NEW=1
    fi
fi

# 更新状态
python3 -c "
import json
state = json.load(open('$STATE_FILE'))
state['lastCommit'] = '$CURRENT_COMMIT'
state['lastCheck'] = '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
json.dump(state, open('$STATE_FILE','w'), indent=2)
"

# 输出结果
if [ "$HAS_NEW" -eq 1 ]; then
    echo "NEW_CONTENT=1"
    echo "COMMIT=$CURRENT_COMMIT"
    echo "FILES=$NEW_FILES"
    exit 1
else
    echo "NEW_CONTENT=0"
    echo "COMMIT=$CURRENT_COMMIT"
    exit 0
fi
