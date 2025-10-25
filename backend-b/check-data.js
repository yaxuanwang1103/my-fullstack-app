import "dotenv/config";
import { connectPostgreSQL, getDB, closeDB } from "./db.js";

async function checkData() {
  try {
    await connectPostgreSQL();
    const db = getDB();
    
    const result = await db.query("SELECT * FROM todos");
    console.log("📊 数据库中的所有记录：");
    console.log(result.rows);
    
    await closeDB();
  } catch (err) {
    console.error("❌ Error:", err);
    process.exit(1);
  }
}

checkData();