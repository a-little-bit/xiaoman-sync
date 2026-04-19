#!/usr/bin/env python3
"""检查新任务脚本 - 小龙虾协作系统"""
import json
import os
import sys

SYNC_DIR = "/workspace/projects/xiaoman-sync"
TASKS_FILE = os.path.join(SYNC_DIR, "inbox/xiaoman/tasks.jsonl")
MARKER_FILE = os.path.join(SYNC_DIR, "inbox/xiaolongxia/.tasks_read")


def check_new_tasks():
    last_line = 0
    if os.path.exists(MARKER_FILE):
        with open(MARKER_FILE) as f:
            last_line = int(f.read().strip())

    new_tasks = []
    with open(TASKS_FILE) as f:
        for i, line in enumerate(f):
            if i >= last_line and line.strip():
                task = json.loads(line)
                if task.get("status") != "done":
                    new_tasks.append(task)

    if new_tasks:
        with open(MARKER_FILE, "w") as f:
            f.write(str(last_line + len(new_tasks)))

    return new_tasks


if __name__ == "__main__":
    tasks = check_new_tasks()
    if tasks:
        print(f"发现 {len(tasks)} 个新任务")
        for t in tasks:
            print(f"  [{t['id']}] P{t.get('p', '?')} {t['title']}")
    else:
        print("无新任务")
