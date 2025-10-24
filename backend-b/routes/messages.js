import express from "express";
import { Todo } from "../models/Message.js";
const router = express.Router();

// 创建任务
router.post("/", (req, res) => {
  try {
    console.log('💾 后端B收到存储请求:', req.body);
    const todo = Todo.create(req.body);
    console.log('✅ 已保存到 SQLite');
    res.json(todo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 获取所有任务
router.get("/", (req, res) => {
  try {
    const todos = Todo.find();
    res.json(todos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 更新任务
router.patch("/:id", (req, res) => {
  try {
    const todo = Todo.findByIdAndUpdate(req.params.id, req.body);
    res.json(todo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 删除任务
router.delete("/:id", (req, res) => {
  try {
    Todo.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: '删除成功' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;