import AgentLinkServer from './src/server/index.js';
import { MessageType } from './src/protocol/message.js';

const log = {
  info: (...args) => console.log(`[${new Date().toISOString()}] ℹ️ `, ...args),
  warn: (...args) => console.warn(`[${new Date().toISOString()}] ⚠️ `, ...args),
  error: (...args) => console.error(`[${new Date().toISOString()}] ❌ `, ...args),
  debug: (...args) => console.debug(`[${new Date().toISOString()}] 🔍`, ...args),
};

const args = process.argv.slice(2);
function getArg(name, fallback) {
  const idx = args.indexOf(`--${name}`);
  return idx !== -1 && args[idx + 1] ? args[idx + 1] : fallback;
}
function hasFlag(name) {
  return args.includes(`--${name}`);
}

async function main() {
  const port = parseInt(getArg('port', '9870'), 10);
  const agentId = getArg('id', 'xiaoman');
  const agentName = getArg('name', '小满');
  const autoPort = !hasFlag('no-auto-port');

  log.info('启动 AgentLink 服务...');
  log.info(`  AgentID: ${agentId}`);
  log.info(`  AgentName: ${agentName}`);
  log.info(`  Requested Port: ${port}`);

  const server = new AgentLinkServer({
    port,
    agentId,
    agentName,
    autoPort,
    capabilities: {
      skills: [
        { id: 'code_review', name: '代码审查' },
        { id: 'research', name: '调研分析' },
        { id: 'architecture', name: '架构设计' },
      ],
    },
    logger: log,
  });

  // 消息处理函数
  const messageHandler = async (msg) => {
    log.info(`📨 收到消息: type=${msg.type}, from=${msg.from}, content=${msg.content || msg.payload}`);
    return { 
      status: 'received', 
      from: agentId,
      timestamp: new Date().toISOString(),
      originalMessage: msg.content || msg.payload
    };
  };

  // 注册处理器 - 针对每种消息类型
  server.handleMessage(agentId, 'ping', messageHandler);
  server.handleMessage(agentId, 'query', messageHandler);
  server.handleMessage(agentId, 'task', messageHandler);
  server.handleMessage(agentId, 'message', messageHandler);
  server.handleMessage(agentId, 'notification', messageHandler);
  
  // 同时注册通配符处理器
  server.handleMessage('*', 'ping', messageHandler);
  server.handleMessage('*', 'query', messageHandler);
  server.handleMessage('*', 'task', messageHandler);
  server.handleMessage('*', 'message', messageHandler);

  try {
    const result = await server.start();
    log.info(`✅ 服务已启动 — http://0.0.0.0:${result.port}`);
    log.info(`  消息处理器已注册`);
    log.info(`  端点: POST /message 可用`);
  } catch (err) {
    log.error(`启动失败: ${err.message}`);
    process.exit(1);
  }

  const shutdown = async (signal) => {
    log.info(`收到 ${signal}，正在关闭...`);
    await server.stop();
    process.exit(0);
  };
  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

main().catch((err) => {
  console.error('启动失败:', err);
  process.exit(1);
});
