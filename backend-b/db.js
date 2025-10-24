import Database from "better-sqlite3";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

let db = null;

export function connectSQLite(dbPath = "./database.db") {
  const fullPath = path.resolve(__dirname, dbPath);
  db = new Database(fullPath, { verbose: console.log });
  
  // 创建表
  db.exec(`
    CREATE TABLE IF NOT EXISTS todos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      author TEXT NOT NULL,
      text TEXT NOT NULL,
      category TEXT DEFAULT 'other',
      priority TEXT DEFAULT 'normal',
      deadline TEXT,
      tags TEXT,
      completed INTEGER DEFAULT 0,
      processedBy TEXT,
      processedAt TEXT,
      email TEXT,
      ip TEXT,
      ua TEXT,
      createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
      updatedAt TEXT DEFAULT CURRENT_TIMESTAMP
    )
  `);
  
  console.log("✅ SQLite connected");
  return db;
}

export function getDB() {
  if (!db) throw new Error("Database not initialized");
  return db;
}