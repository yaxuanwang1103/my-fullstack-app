import { useState, useEffect } from 'react';
import axios from 'axios';

function App() {
  const [todos, setTodos] = useState([]);
  const [task, setTask] = useState('');

  // 页面一打开就从后端拿数据
  useEffect(() => {
    axios.get('http://localhost:3000/api/messages').then(res => setTodos(res.data.items || []));
  }, []);

  // 添加新任务
  const addTodo = async () => {
    if (!task.trim()) return;
    const res = await axios.post('http://localhost:3000/api/messages', { 
  author: '匿名用户',
  text: task 
});
    setTodos([...todos, res.data]);
    setTask('');
  };

  return (
    <div style={{ padding: 20, fontFamily: 'sans-serif' }}>
      <h1>我的待办清单</h1>
      <div style={{ marginBottom: 12 }}>
        <input
          value={task}
          onChange={e => setTask(e.target.value)}
          placeholder="写点要做的事..."
          style={{ padding: 8, marginRight: 8 }}
        />
        <button onClick={addTodo} style={{ padding: '8px 12px' }}>
          添加
        </button>
      </div>
      <ul>
        {todos.map(t => (
       <li key={t._id}>{t.text}</li>  
        ))}
      </ul>
    </div>
  );
}

export default App;

