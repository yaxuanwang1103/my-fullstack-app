// migrate-data.js
import Database from "better-sqlite3";
import pg from "pg";
import "dotenv/config";

const { Pool } = pg;

async function migrate() {
  // 连接 SQLite
  const sqlite = new Database("./database.db");
  const rows = sqlite.prepare("SELECT * FROM todos").all();
  
  // 连接 PostgreSQL
  const pool = new Pool({
    host: process.env.POSTGRES_HOST,
    port: process.env.POSTGRES_PORT,
    database: process.env.POSTGRES_DB,
    user: process.env.POSTGRES_USER,
    password: process.env.POSTGRES_PASSWORD,
  });
  
  // 迁移数据
  for (const row of rows) {
    await pool.query(
      `INSERT INTO todos (
        author, text, category, priority, deadline, tags,
        completed, "processedBy", "processedAt", email, ip, ua,
        "createdAt", "updatedAt"
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)`,
      [
        row.author, row.text, row.category, row.priority,
        row.deadline, row.tags, row.completed, row.processedBy,
        row.processedAt, row.email, row.ip, row.ua,
        row.createdAt, row.updatedAt
      ]
    );
  }
  
  console.log(`✅ 迁移完成：${rows.length} 条记录`);
  await pool.end();
  sqlite.close();
}

migrate();