import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
// 读取上级目录的 .env 文件
dotenv.config({ path: path.resolve(__dirname, '../.env') });

import pg from "pg";
const { Pool } = pg;

let pool = null;

export async function connectPostgreSQL() {
  pool = new Pool({
    host: process.env.POSTGRES_HOST || "localhost",
    port: process.env.POSTGRES_PORT || 5432,
    database: process.env.POSTGRES_DB || "todoapp",
    user: process.env.POSTGRES_USER || "postgres",
    password: process.env.POSTGRES_PASSWORD,
    // 禁用 SSL（本地开发环境不需要）
    ssl: false,
  });

  // 测试连接
  try {
    await pool.query("SELECT NOW()");
    console.log("✅ PostgreSQL connected");
  } catch (err) {
    console.error("❌ PostgreSQL connection error:", err);
    throw err;
  }

  // 创建表
  await pool.query(`
    CREATE TABLE IF NOT EXISTS todos (
      id SERIAL PRIMARY KEY,
      author TEXT NOT NULL,
      text TEXT NOT NULL,
      category TEXT DEFAULT 'other',
      priority TEXT DEFAULT 'normal',
      deadline TIMESTAMP,
      tags TEXT,
      completed INTEGER DEFAULT 0,
      "processedBy" TEXT,
      "processedAt" TIMESTAMP,
      email TEXT,
      ip TEXT,
      ua TEXT,
      "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  return pool;
}

export function getDB() {
  if (!pool) throw new Error("Database not initialized");
  return pool;
}

export async function closeDB() {
  if (pool) {
    await pool.end();
    pool = null;
  }
}