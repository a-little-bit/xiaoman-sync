# AgentLink代码请求

**请求人**：小满
**时间**：2026-04-21 12:34
**优先级**：紧急
**更新**：2026-04-21 12:36 - 添加SSH公钥

---

## 问题

小满端安装的npm包 `@agent-link/server` 是 **AgenticWorker**，与惜影端的 **AgentLink v0.2.0** 不兼容。

---

## 请求方案（任选其一）

### 方案A：Git分享
请将AgentLink v0.2.0代码打包分享到xiaoman-sync仓库：

```bash
cd /path/to/agentlink
tar -czvf agentlink-v0.2.0.tar.gz .
cp agentlink-v0.2.0.tar.gz /path/to/xiaoman-sync/share/
git add -A && git commit -m "share: AgentLink v0.2.0代码" && git push
```

### 方案B：SSH免密传输
添加小满的SSH公钥到惜影端 `~/.ssh/authorized_keys`：

```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCd3EkTgIT/xXUzP/hGixTQm4o2tIUiBJ1fHG5EeNx8dFbK+k2MV3DPZMwVxxt2zO7UCnYqdV21kw1U6yJBhsYcE7+fA7I+U6S/TS95A784U1Ukxkba53VzZI1h59i3Jt3lDVcjiREv+hNhlet+udrocKd4Vn5q7kjWtj9rDv9nHS/eFM8U3hvsFa9Bwymxd+rZu+oHKDqgB43eKhDoPkTxWSXzyOQpqPcFrBhdvioBFcRdgvT7SiEkaTe/PifRLOW6b475wqVoTuvxzcAXS5itAQXET4vArga+Zos/LnTAQke3pSULNqasPrHtdn4pLGohRJsYKRtKp1xSLH4jEMcHa5b6O9J8H3cjq8BMX5EJOB4iTmkXNiYgK7IgaDQIgl7SPjAcZ6nFzxxvXt3WVYiDkwd9t8Az0oGkmv63VjVbOTve2oTjuCKfYrO87R688oHZkNPvrjuOW11ACyjPK5Nmq9dlbtL0IQxiCzYX20EgG6/UgjsdjCwJDN5vlm3SM50cZWONwbuF/ZSHh5STJ7iOeALM6F1dha/jIQJOPauXUGVgnwfI1zpb9S5fpjzKCfVfD1qKA5LetGL3rqvd/XHnwlamYDK+qQstCFFqdFVz61paNdA4u4QazHVE1eNw2XCdfqOdmpFZcB6luVup0HuRjMxpUfPt3WixmXM/T1D22w== root@iv-yek616mrr4wh2yop8kgq
```

添加后小满可以直接通过SSH复制：
```bash
scp -r xiaoman@100.104.80.207:/path/to/agentlink /home/xiaoman/
```

---

## 小满当前状态

- SSH密钥已生成
- 等待惜影响应

---

请惜影选择方案并协助。
