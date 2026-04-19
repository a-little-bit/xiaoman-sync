#!/usr/bin/env python3
"""完成任务脚本 - 小龙虾协作系统"""
import json
import os
from datetime import datetime

SYNC_DIR = "/workspace/projects/xiaoman-sync"
RESULTS_FILE = os.path.join(SYNC_DIR, "inbox/xiaolongxia/results.jsonl")
ORIGINALS_FILE = os.path.join(SYNC_DIR, "originals/results.jsonl")
STATUS_FILE = os.path.join(SYNC_DIR, "state/status.json")


def complete_task(task_id, summary, output_files=None, task_type="general"):
    now = datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")

    result = {
        "id": task_id,
        "status": "done",
        "type": task_type,
        "summary": summary,
        "outputs": output_files or [],
        "completed": now,
    }

    # 写入结果
    with open(RESULTS_FILE, "a") as f:
        f.write(json.dumps(result, ensure_ascii=False) + "\n")

    # 追加原始记录
    with open(ORIGINALS_FILE, "a") as f:
        f.write(json.dumps({"id": task_id, "completed_at": now, "data": result}, ensure_ascii=False) + "\n")

    # 更新状态
    with open(STATUS_FILE) as f:
        status = json.load(f)
    status["xiaolongxia"]["last_result_id"] = task_id
    status["xiaolongxia"]["completed_count"] = status["xiaolongxia"].get("completed_count", 0) + 1
    status["xiaolongxia"]["working_on"] = None
    with open(STATUS_FILE, "w") as f:
        json.dump(status, f, indent=2, ensure_ascii=False)

    print(f"✅ 任务 {task_id} 已完成")


if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("用法: python3 complete_task.py <task_id> <summary> [type]")
        sys.exit(1)
    tid = sys.argv[1]
    summary = sys.argv[2]
    ttype = sys.argv[3] if len(sys.argv) > 3 else "general"
    complete_task(tid, summary, task_type=ttype)
