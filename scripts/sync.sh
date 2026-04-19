#!/bin/bash
cd "$(dirname "$0")/.."
echo "=== 开始同步 ==="
git pull github main --rebase 2>/dev/null || git pull github main
git pull gitee main --rebase 2>/dev/null || git pull gitee main
git push github main
git push gitee main
echo "=== 同步完成 ==="
