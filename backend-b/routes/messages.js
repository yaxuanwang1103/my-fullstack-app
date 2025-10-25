import express from "express";
import { getDB } from "../db.js";

const router = express.Router();

// 获取所有消息
router.get("/", async (req, res) => {
  try {
    const db = getDB();
    const result = await db.query("SELECT * FROM todos ORDER BY id DESC");
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch messages" });
  }
});

// 创建消息
router.post("/", async (req, res) => {
  try {
    const db = getDB();
    const {
      author,
      text,
      category,
      priority,
      deadline,
      tags,
      processedBy,
      processedAt,
      email,
      ip,
      ua,
    } = req.body;

    const result = await db.query(
      `INSERT INTO todos (
        author, text, category, priority, deadline, tags,
        "processedBy", "processedAt", email, ip, ua
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      RETURNING *`,
      [
        author || "匿名",
        text,
        category || "other",
        priority || "normal",
        deadline || null,
        tags || null,
        processedBy || null,
        processedAt || null,
        email || null,
        ip || null,
        ua || null,
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to create message" });
  }
});

// 更新消息
router.put("/:id", async (req, res) => {
  try {
    const db = getDB();
    const { id } = req.params;
    const { completed } = req.body;

    const result = await db.query(
      `UPDATE todos SET completed = $1, "updatedAt" = CURRENT_TIMESTAMP 
       WHERE id = $2 RETURNING *`,
      [completed ? 1 : 0, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Message not found" });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update message" });
  }
});

// 删除消息
router.delete("/:id", async (req, res) => {
  try {
    const db = getDB();
    const { id } = req.params;

    const result = await db.query("DELETE FROM todos WHERE id = $1 RETURNING *", [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Message not found" });
    }

    res.json({ message: "Deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to delete message" });
  }
});

export default router;