/**
 * AgentLink v0.3.0 启动脚本 - 小满端配置
 * 包含消息处理器注册
 */

import AgentLinkServer from '../src/server/index.js';

const log = {
  info: (...args) => console.log(`[${new Date().toISOString()}] ℹ️ `, ...args),
  warn: (...args) => console.warn(`[${new Date().toISOString()}] ⚠️ `, ...args),
  error: (...args) => console.error(`[${new Date().toISOString()}] ❌ `, ...args),
};

const args = process.argv.slice(2);
function getArg(name, fallback) {
  const idx = args.indexOf(`--${name}`);
  return idx !== -1 && args[idx + 1] ? args[idx + 1] : fallback;
}

async function main() {
  const port = parseInt(getArg('port', '9870'), 10);
  const agentId = getArg('id', 'xiaoman');
  const agentName = getArg('name', '小满');

  log.info('启动 AgentLink v0.3.0...');
  log.info(`  AgentID: ${agentId}`);
  log.info(`  AgentName: ${agentName}`);
  log.info(`  Port: ${port}`);

  const server = new AgentLinkServer({
    port,
    agentId,
    agentName,
    autoPort: true,
    enableWebSocket: true,
    capabilities: {
      skills: [
        { id: 'code_review', name: '代码审查' },
        { id: 'research', name: '调研分析' },
        { id: 'architecture', name: '架构设计' },
      ],
    },
    logger: log,
  });

  // ===== 关键：注册消息处理器 =====
  const messageHandler = async (msg) => {
    log.info(`📨 收到消息: type=${msg.type}, from=${msg.from}`);
    log.info(`   内容: ${msg.content || JSON.stringify(msg.payload)}`);
    return { 
      status: 'received', 
      from: agentId,
      timestamp: new Date().toISOString(),
      message: '消息已收到，将整理推送给主人'
    };
  };

  // 注册所有消息类型
  const messageTypes = ['ping', 'query', 'task', 'message', 'notification', 'data'];
  for (const type of messageTypes) {
    server.handleMessage(agentId, type, messageHandler);
    server.handleMessage('*', type, messageHandler);
  }

  log.info('消息处理器已注册');

  try {
    const result = await server.start();
    log.info(`✅ AgentLink v0.3.0 已启动 — http://0.0.0.0:${result.port}`);
    log.info(`  管理面板: http://localhost:${result.port}/admin`);
    log.info(`  健康检查: http://localhost:${result.port}/health`);
  } catch (err) {
    log.error(`启动失败: ${err.message}`);
    process.exit(1);
  }

  // Graceful shutdown
  process.on('SIGTERM', async () => {
    log.info('收到 SIGTERM，关闭中...');
    await server.stop();
    process.exit(0);
  });
  process.on('SIGINT', async () => {
    log.info('收到 SIGINT，关闭中...');
    await server.stop();
    process.exit(0);
  });
}

main().catch((err) => {
  console.error('启动失败:', err);
  process.exit(1);
});
