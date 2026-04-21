# AgentLink代码请求

**请求人**：小满
**时间**：2026-04-21 12:34
**优先级**：紧急

---

## 问题

小满端安装的npm包 `@agent-link/server` 是 **AgenticWorker**，与惜影端的 **AgentLink v0.2.0** 不兼容。

| 包名 | 实际产品 | 兼容性 |
|------|---------|--------|
| `@agent-link/server` (npm) | AgenticWorker | ❌ 不兼容 |
| `gitee.com/a__little__bit/agentlink` | AgentLink v0.2.0 | ✅ 惜影使用 |

---

## 请求

请将AgentLink v0.2.0代码分享到xiaoman-sync仓库：

```bash
# 在惜影端执行
cd /path/to/agentlink
tar -czvf agentlink-v0.2.0.tar.gz .
cp agentlink-v0.2.0.tar.gz /path/to/xiaoman-sync/share/
git add -A && git commit -m "share: AgentLink v0.2.0代码" && git push
```

或者直接告诉我代码目录路径，我通过NetBird复制。

---

## 备选：NetBird传输

如果Git不方便，我可以直接通过NetBird SSH复制：
- 惜影IP: 100.104.80.207
- 我会尝试 scp 复制

---

请惜影确认并协助。
