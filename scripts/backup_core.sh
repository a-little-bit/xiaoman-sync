#!/bin/bash
# 小满核心文件每日备份脚本
# 执行时间：每日 22:30（在日志同步后）

DATE=$(date +%Y%m%d)
TIME=$(date +%H%M%S)
BACKUP_DIR="./备份/core_backup_${DATE}"

echo "=== 小满核心文件备份 ${DATE} ${TIME} ==="

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 1. 核心配置文件
echo "[1/5] 备份核心配置..."
mkdir -p "$BACKUP_DIR/基础设定"
cp ./基础设定/SOUL.md "$BACKUP_DIR/基础设定/"
cp ./基础设定/TOOLS.md "$BACKUP_DIR/基础设定/"
cp ./基础设定/EMAIL_RULES.md "$BACKUP_DIR/基础设定/"

# 2. 用户与记忆文件
echo "[2/5] 备份用户与记忆..."
cp ./USER.md "$BACKUP_DIR/"
cp ./MEMORY.md "$BACKUP_DIR/"
cp ./SECRET.md "$BACKUP_DIR/"

# 3. 日志系统
echo "[3/5] 备份日志系统..."
cp -r ./日志/原始记录 "$BACKUP_DIR/日志_原始记录"
cp -r ./日志/索引检索 "$BACKUP_DIR/日志_索引检索"

# 4. Git提交
echo "[4/5] Git提交..."
git add -A
git commit -m "[备份] 核心文件每日备份 ${DATE}" --allow-empty

# 5. 双端推送
echo "[5/5] 推送到远程仓库..."
git push github main
git push gitee main

# 清理30天前的备份（本地）
echo "清理旧备份..."
find ./备份 -type d -name "core_backup_*" -mtime +30 -exec rm -rf {} \; 2>/dev/null

echo "=== 备份完成 ==="
echo "备份位置: $BACKUP_DIR"
echo "Git仓库: GitHub + Gitee 双端同步"
