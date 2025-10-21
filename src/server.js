import "dotenv/config";
import express from "express";
import cors from "cors";
import rateLimit from "express-rate-limit";
import { connectMongo } from "./db.js";
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
const PORT = process.env.PORT || 3000;
const MONGO_URL = process.env.MONGO_URL || "mongodb://127.0.0.1:27017/board";

connectMongo(MONGO_URL)
  .then(() => {
    app.listen(PORT, () => console.log(`🚀 API ready: http://localhost:${PORT}`));
  })
  .catch((err) => {
    console.error("❌ Mongo connect error:", err);
    process.exit(1);
  });
