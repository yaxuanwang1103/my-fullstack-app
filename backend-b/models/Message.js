import { getDB } from "../db.js";

export class Todo {
  // 创建任务
  static create(data) {
    const db = getDB();
    const stmt = db.prepare(`
      INSERT INTO todos (author, text, category, priority, deadline, tags, completed, processedBy, processedAt, email, ip, ua)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);
    
    const info = stmt.run(
      data.author,
      data.text,
      data.category || 'other',
      data.priority || 'normal',
      data.deadline || null,
      data.tags ? JSON.stringify(data.tags) : null,
      data.completed ? 1 : 0,
      data.processedBy || null,
      data.processedAt || null,
      data.email || null,
      data.ip || null,
      data.ua || null
    );
    
    return this.findById(info.lastInsertRowid);
  }
  
  // 查询所有任务
  static find() {
    const db = getDB();
    const stmt = db.prepare('SELECT * FROM todos ORDER BY createdAt DESC');
    const rows = stmt.all();
    
    return rows.map(row => ({
      ...row,
      _id: row.id,
      completed: Boolean(row.completed),
      tags: row.tags ? JSON.parse(row.tags) : [],
      deadline: row.deadline || undefined
    }));
  }
  
  // 根据 ID 查询
  static findById(id) {
    const db = getDB();
    const stmt = db.prepare('SELECT * FROM todos WHERE id = ?');
    const row = stmt.get(id);
    
    if (!row) return null;
    
    return {
      ...row,
      _id: row.id,
      completed: Boolean(row.completed),
      tags: row.tags ? JSON.parse(row.tags) : [],
      deadline: row.deadline || undefined
    };
  }
  
  // 更新任务
  static findByIdAndUpdate(id, data) {
    const db = getDB();
    const updates = [];
    const values = [];
    
    if (data.author !== undefined) { updates.push('author = ?'); values.push(data.author); }
    if (data.text !== undefined) { updates.push('text = ?'); values.push(data.text); }
    if (data.category !== undefined) { updates.push('category = ?'); values.push(data.category); }
    if (data.priority !== undefined) { updates.push('priority = ?'); values.push(data.priority); }
    if (data.deadline !== undefined) { updates.push('deadline = ?'); values.push(data.deadline); }
    if (data.tags !== undefined) { updates.push('tags = ?'); values.push(JSON.stringify(data.tags)); }
    if (data.completed !== undefined) { updates.push('completed = ?'); values.push(data.completed ? 1 : 0); }
    if (data.processedBy !== undefined) { updates.push('processedBy = ?'); values.push(data.processedBy); }
    if (data.processedAt !== undefined) { updates.push('processedAt = ?'); values.push(data.processedAt); }
    
    updates.push('updatedAt = CURRENT_TIMESTAMP');
    values.push(id);
    
    const stmt = db.prepare(`UPDATE todos SET ${updates.join(', ')} WHERE id = ?`);
    stmt.run(...values);
    
    return this.findById(id);
  }
  
  // 删除任务
  static findByIdAndDelete(id) {
    const db = getDB();
    const stmt = db.prepare('DELETE FROM todos WHERE id = ?');
    stmt.run(id);
    return { success: true };
  }
}