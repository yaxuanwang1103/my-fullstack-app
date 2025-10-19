// backend/server.js
const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// 让你知道服务器是不是活着
app.get('/api/health', (req, res) => {
    res.json({ ok: true, time: new Date().toISOString() });
});

// 连接或创建数据库文件（同目录下会生成 database.db）
const db = new sqlite3.Database('./database.db', (err) => {
    if (err) console.error('数据库连接失败：', err);
    else console.log('SQLite 已连接');
});

// 建表：todos（如果没有就创建）
db.run(`CREATE TABLE IF NOT EXISTS todos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task TEXT NOT NULL
)`);

// 读全部待办
app.get('/api/todos', (req, res) => {
    db.all('SELECT * FROM todos', (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

// 新增待办
app.post('/api/todos', (req, res) => {
    const { task } = req.body;
    if (!task || !task.trim()) return res.status(400).json({ error: 'task 不能为空' });
    db.run('INSERT INTO todos (task) VALUES (?)', [task.trim()], function (err) {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ id: this.lastID, task: task.trim() });
    });
});

// 启动后端
const PORT = 5174;
app.listen(PORT, () => console.log(`后端已启动：http://localhost:${PORT}`));
