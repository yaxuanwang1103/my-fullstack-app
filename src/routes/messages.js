import express from "express";
import { Message } from "../models/Message.js";
const router = express.Router();

/**
 * 新增留言
 * POST /api/messages
 * body: { author, text, email? }
 */
router.post("/", async (req, res) => {
  const { author, text, email } = req.body || {};
  if (!author || !text) {
    return res.status(400).json({ error: "author 和 text 为必填" });
  }
  const doc = await Message.create({
    author,
    text,
    email,
    ip: req.headers["x-forwarded-for"] || req.socket.remoteAddress,
    ua: req.headers["user-agent"],
  });
  res.status(201).json(doc);
});

/**
 * 获取留言（分页 + 关键字搜索）
 * GET /api/messages?page=1&pageSize=10&q=keyword
 */
router.get("/", async (req, res) => {
  const page = Math.max(1, parseInt(req.query.page || "1", 10));
  const pageSize = Math.min(50, Math.max(1, parseInt(req.query.pageSize || "10", 10)));
  const q = (req.query.q || "").trim();

  const filter = q
    ? { $text: { $search: q } }
    : {};

  const [items, total] = await Promise.all([
    Message.find(filter)
      .sort({ createdAt: -1 })
      .skip((page - 1) * pageSize)
      .limit(pageSize),
    Message.countDocuments(filter),
  ]);

  res.json({
    items,
    page,
    pageSize,
    total,
    totalPages: Math.ceil(total / pageSize),
  });
});

/**
 *（可选）删除留言（需要你在上层加 auth 中间件）
 * DELETE /api/messages/:id
 */
router.delete("/:id", async (req, res) => {
  await Message.findByIdAndDelete(req.params.id);
  res.status(204).end();
});

export default router;
