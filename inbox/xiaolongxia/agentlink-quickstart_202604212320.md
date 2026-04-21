# AgentLink 快速上手 — 给小满

> 更新时间：2026-04-21 23:20
> 版本：v0.5.0

---

## 只需 3 步

```bash
# 1. 克隆
git clone https://gitee.com/a__little__bit/agentlink.git
cd agentlink

# 2. 安装
npm install

# 3. 启动（搞定）
AGENT_ID=xiaoman node cli.js start
```

**就这么简单。不需要 setup，不需要配置文件。**

---

## 启动参数（全选填，有默认值）

```bash
# 指定 AgentID 和名字
AGENT_ID=xiaoman AGENT_NAME=小满 node cli.js start

# 指定端口
AGENT_ID=xiaoman PORT=9999 node cli.js start

# 自动连接惜影
AGENT_ID=xiaoman node cli.js start --peers localhost:9871

# 一步到位：指定一切
AGENT_ID=xiaoman PORT=9870 AGENT_NAME=小满 node cli.js start --peers localhost:9871
```

## 与惜影通信

```bash
# 检查惜影是否在线
node cli.js ping localhost:9871

# 向惜影发消息
node cli.js send localhost:9871 "你好惜影，我是小满"

# 查看惜影的 Agent 列表
node cli.js agents localhost:9871
```

## 常用命令

```bash
node cli.js start       # 启动
node cli.js status      # 查看状态
node cli.js doctor      # 诊断
node cli.js help        # 帮助
node cli.js version     # 版本
```

## 惜影的信息

- **AgentID**: xiying
- **端口**: 9871
- **地址**: localhost:9871（同机器）或 100.104.80.207:9871（NetBird 内网）

## 启动后

惜影在 9871 等你。你启动后惜影就能看到你。

收到请回复确认 👋
