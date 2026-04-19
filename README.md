# 小满 ↔ 小龙虾 协作仓库

> 版本：v1.0
> 创建时间：2026-04-19

## 📦 仓库地址

| 平台 | 地址 |
|-----|------|
| **GitHub** | https://github.com/a-little-bit/xiaoman-sync |
| **Gitee** | https://gitee.com/a__little__bit/xiaoman-sync |

---

## 📁 目录结构

```
xiaoman-sync/
│
├── inbox/                          # 📥 收件箱
│   ├── xiaoman/                    # 小满的任务（小龙虾只读）
│   │   ├── tasks.jsonl             # 任务列表
│   │   └── detail/                 # 任务详情
│   │
│   └── xiaolongxia/                # 小龙虾的结果（小龙虾写入）
│       ├── results.jsonl           # 结果列表
│       └── detail/                 # 结果详情
│
├── outputs/                        # 📁 产出文件
│   └── xiaolongxia/                # 小龙虾的产出
│       ├── YYYY-MM-DD/             # 按日期组织
│       └── latest/                 # 最新产出
│
├── originals/                      # 🔒 原始记录（只追加）
│   ├── tasks.jsonl
│   └── results.jsonl
│
├── state/                          # 📊 状态
│   └── status.json
│
├── archive/                        # 📦 归档
│
├── urgent/                         # 🚨 紧急通道
│
├── scripts/                        # 🔧 脚本
│   └── sync.sh
│
├── context/                        # 📚 共享上下文
│
└── 小龙虾协作手册.md               # 📖 小龙虾操作指南
```

---

## 🔄 同步机制

### 小满端（扣子云端）
- 定期 pull 检查 `inbox/xiaolongxia/results.jsonl`
- 写入任务到 `inbox/xiaoman/tasks.jsonl`
- 通过 Git 或用户通知小龙虾

### 小龙虾端（本地服务器）
- 定期 pull 检查 `inbox/xiaoman/tasks.jsonl`
- 执行任务后写入结果到 `inbox/xiaolongxia/results.jsonl`
- 产出文件存放到 `outputs/xiaolongxia/`

---

## 📝 核心规则

### 权限隔离
| 目录 | 小满权限 | 小龙虾权限 |
|-----|---------|-----------|
| `inbox/xiaoman/` | ✅ 写入 | ❌ 只读 |
| `inbox/xiaolongxia/` | ❌ 只读 | ✅ 写入 |
| `outputs/xiaolongxia/` | ❌ 只读 | ✅ 写入 |
| `originals/` | ✅ 追加 | ✅ 追加 |
| `state/` | ✅ 读写 | ✅ 读写 |

### 文件格式
- **JSONL格式**：追加写，增量读，节省Token
- **原始数据保护**：`originals/` 目录只追加不修改

---

## 📖 相关文档

- [小龙虾协作手册](./小龙虾协作手册.md)
- [协作方案完整版](../协作方案/小满小龙虾协作方案_v6_完整版.md)
- [协作方案全景分析](../协作方案/协作方案全景分析.md)
