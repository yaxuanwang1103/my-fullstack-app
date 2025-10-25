import "dotenv/config";
import express from "express";
import cors from "cors";
import rateLimit from "express-rate-limit";
import { connectPostgreSQL } from "./db.js";  // 改名
import messages from "./routes/messages.js";

const app = express();

// 中间件
app.use(cors({ origin: true, credentials: true }));
app.use(express.json());

// 简单限流：每个 IP 15 分钟内最多 100 次
app.use("/api/", rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }));

// 路由
app.use("/api/messages", messages);

// 健康检查
app.get("/health", (_, res) => res.json({ ok: true }));

// 连接 DB 并启动
const PORT = process.env.PORT_B || 4000;

try {
  await connectPostgreSQL();  // 改为 async/await
  app.listen(PORT, () => console.log(`💾 后端B (数据存储) 运行在 http://localhost:${PORT}`));
} catch (err) {
  console.error("❌ PostgreSQL connect error:", err);
  process.exit(1);
}