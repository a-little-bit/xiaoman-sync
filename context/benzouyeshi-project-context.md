# 奔走夜市 (BenzouYeShi) — 项目上下文

> 最后更新：2026-04-19
> 维护者：息影（小龙虾/xiaolongxia）

---

## 一、项目概述

**奔走夜市**是一个面向亿级用户的多端地摊经济 O2O 平台。
用户（买家）可以基于 LBS 发现附近摊位、浏览商品、在线下单；
摊主（卖家）可以管理商品、处理订单、查看收入统计。
平台端提供用户管理、内容审核、数据分析、营销工具。

### 核心差异化
- O2O 双端（买家 + 卖家）
- 地图 LBS 发现附近摊位
- 摊主实名认证体系
- 亿级架构设计（微服务 + 分库分表）

### 竞品分析
- **垂直竞品**：掌柜365、摊天下、喜市、云摊集、地摊兄
- **广义竞品**：闲鱼、转转、全来店
- **关键洞察**：现有产品多偏"摆摊工具"（帮摊主经营），缺"消费者端"体验

---

## 二、代码仓库

- **GitHub**: https://github.com/a-little-bit/benzouyeshi
- **Gitee**: https://gitee.com/a__little__bit/benzouyeshi
- **本地路径**: `/workspace/projects/workspace/ditan-app/`

---

## 三、技术栈

| 层级 | 技术选型 |
|------|----------|
| 后端 | Spring Boot 3 + Spring Cloud + MyBatis-Plus |
| 数据库 | MySQL（前缀 `bzy_`）|
| 缓存 | Redis |
| 消息队列 | RabbitMQ |
| 对象存储 | MinIO |
| Web 前端 | Next.js 14 (App Router) + Arco Design + 橙黄暖色系主题 |
| 小程序 | Taro 3.x (React + TypeScript) |
| 网关 | Spring Cloud Gateway + JWT + Sentinel 限流 |
| 认证 | 双 Token（Access + Refresh）|
| 部署 | Docker / K8s |

### Java 包名
`com.benzouyeshi`

### 数据库表前缀
`bzy_`

---

## 四、项目结构

```
ditan-app/
├── apps/              # 后端微服务（Spring Boot）
│   ├── gateway/       # API 网关（端口 8080）
│   ├── user-service/  # 用户服务（端口 8081）— 注册/登录/认证/双Token
│   ├── product-service/  # 商品服务（端口 8082）— 商品/分类/评论/库存
│   ├── order-service/    # 订单服务（端口 8083）
│   ├── payment-service/  # 支付服务（端口 8084）
│   ├── admin-backend/    # 管理后台 API（端口 8085）
│   └── shared-utils/     # 公共模块
├── web/               # Web 前端（Next.js + Arco Design）
│   ├── 14 个页面
│   └── 暖橙渐变主题 + 深色管理后台
├── mobile/            # 小程序（Taro 3.x）
│   ├── 9 个页面
│   ├── 4 个公共组件
│   └── API 请求层 + 状态管理
├── packages/          # 共享包
├── infra/             # 基础设施配置（Docker/K8s/CI-CD）
├── docs/              # 文档
├── scripts/           # 脚本
└── test-shots/        # 测试截图
```

---

## 五、后端模块详情

| 模块 | 端口 | 核心能力 |
|------|------|----------|
| gateway | 8080 | API 网关、JWT 鉴权、路由、Sentinel 限流 |
| user-service | 8081 | 注册、登录、短信登录、双Token、用户资料、头像上传、摊主认证 |
| product-service | 8082 | 商品 CRUD、分类管理、评论、库存管理 |
| order-service | 8083 | 订单创建、状态流转、支付回调 |
| payment-service | 8084 | 支付集成、退款 |
| admin-backend | 8085 | 管理后台、数据统计、内容审核 |

---

## 六、前端模块详情

### Web 端（15 页面）
- 首页（暖橙渐变 Banner + 8 大分类网格 + 附近摊位卡片）
- 登录页、注册页
- 商品列表、商品详情
- 摊主管理后台（深色侧边栏 + 米白内容区）
- 订单管理、购物车
- 个人中心、消息中心
- 等

### 小程序端（9 页面）
- 首页、分类、商品详情、购物车
- 发布商品、订单、消息
- 个人中心、登录、摊位地图
- 4 个公共组件 + 完整 API 层 + 状态管理

---

## 七、当前进度（截至 2026-04-19）

### ✅ 已完成
- [x] 全栈项目脚手架生成（后端 9 模块 + Web 14 页面 + 小程序 9 页面 + 基础设施 80 文件）
- [x] Maven 编译修复
- [x] 前端构建修复（Arco Design 改造）
- [x] 全量重命名：ditan → benzouyeshi（334 文件）
- [x] GitHub + Gitee 双仓同步
- [x] 一键部署脚本
- [x] 后端 Week1 核心模块开发（用户认证 + 商品体系 + 摊主认证）
- [x] 前端 15 页面开发
- [x] Next.js dev server 运行验证通过
- [x] 竞品调研
- [x] 远程服务器部署（Ubuntu 24.04）

### 🔄 进行中 / 待办
- [ ] 后端 TDD 单元测试
- [ ] 前后端联调
- [ ] 远程服务器部署新代码验证
- [ ] 重试 GitHub 推送（TLS 失败问题）

---

## 八、部署信息

- **远程服务器**: Ubuntu 24.04, 7GB RAM, 84GB Disk
- **部署脚本**: `scripts/deploy-remote.sh`

---

## 九、飞书集成

- 飞书应用已配置
- 飞书会话 ID: `oc_288d1cc1cebc5882d92af1463cb64ce1`
- 程飞要求后续消息推送到飞书

---

*本文档由息影维护，供协作方（小满）参考。如有变更请及时更新。*
