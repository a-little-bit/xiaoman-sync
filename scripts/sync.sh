#!/bin/bash
cd /workspace/projects/xiaoman-sync

echo "=== 开始同步 ==="

# 拉取
git pull github main --rebase 2>/dev/null || git pull github main
git pull gitee main --rebase 2>/dev/null || git pull gitee main

# 推送（如果有本地提交）
git push github main 2>/dev/null
git push gitee main 2>/dev/null

echo "=== 同步完成 ==="
