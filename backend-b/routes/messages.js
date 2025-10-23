import express from "express";
import { Todo } from "../models/Message.js";
const router = express.Router();

// 创建任务
router.post("/", async (req, res) => {
  try {
    console.log('💾 后端B收到存储请求:', req.body);
    const todo = await Todo.create(req.body);
    console.log('✅ 已保存到 MongoDB');
    res.json(todo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 获取所有任务
router.get("/", async (req, res) => {
  try {
    const todos = await Todo.find().sort({ createdAt: -1 });
    res.json(todos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 更新任务
router.patch("/:id", async (req, res) => {
  try {
    const todo = await Todo.findByIdAndUpdate(
      req.params.id, 
      req.body, 
      { new: true }
    );
    res.json(todo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 删除任务
router.delete("/:id", async (req, res) => {
  try {
    await Todo.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: '删除成功' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;