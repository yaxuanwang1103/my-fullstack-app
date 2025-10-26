import { useState, useEffect } from 'react';
import axios from 'axios';

function App() {
  const [todos, setTodos] = useState([]);
  const [stats, setStats] = useState(null);
  const [task, setTask] = useState('');
  const [message, setMessage] = useState('');

  // 获取数据
  useEffect(() => {
    fetchTodos();
  }, []);

  const fetchTodos = () => {
    const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:3000';
    axios.get(`${API_BASE}/api/messages`).then(res => {
      setTodos(res.data.items || []);
      setStats(res.data.stats);
    });
  };

  // 添加任务
  const addTodo = async () => {
    if (!task.trim()) return;
    
    try {
      const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:3000';
      const res = await axios.post(`${API_BASE}/api/messages`, { 
        author: '匿名用户',
        text: task 
      });
      
      // 显示智能分析结果
      setMessage(res.data.message);
      setTimeout(() => setMessage(''), 3000);
      
      // 刷新列表
      fetchTodos();
      setTask('');
    } catch {
      setMessage('❌ 添加失败');
    }
  };

  // 获取类别图标和名称
  const getCategoryDisplay = (category) => {
    const display = {
      work: { icon: '💼', name: '工作' },
      study: { icon: '📚', name: '学习' },
      life: { icon: '🏠', name: '生活' },
      other: { icon: '📝', name: '其他' }
    };
    return display[category] || display.other;
  };

  // 获取优先级颜色和名称
  const getPriorityDisplay = (priority) => {
    const display = {
      high: { color: '#ff4444', name: '高' },
      normal: { color: '#4444ff', name: '中' },
      low: { color: '#44ff44', name: '低' }
    };
    return display[priority] || display.normal;
  };

  return (
    <div style={{ 
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      padding: 20,
      fontFamily: 'sans-serif'
    }}>
      <div style={{ maxWidth: 800, margin: '0 auto' }}>
        <h1 style={{ color: 'white', textShadow: '2px 2px 4px rgba(0,0,0,0.3)' }}>
          🤖 智能待办清单
        </h1>
        <p style={{ color: 'rgba(255,255,255,0.9)', fontSize: 14 }}>
          后端A和B协作处理 - 自动分类和优先级识别
        </p>
      
      {/* 消息提示 */}
      {message && (
        <div style={{ 
          padding: 10, 
          background: '#e8f5e9', 
          border: '1px solid #4caf50',
          borderRadius: 5,
          marginBottom: 15
        }}>
          {message}
        </div>
      )}
      
      {/* 统计信息 */}
      {stats && (
        <div style={{ 
          marginBottom: 20, 
          padding: 15, 
          background: 'rgba(255,255,255,0.95)', 
          borderRadius: 8,
          boxShadow: '0 4px 12px rgba(0,0,0,0.15)'
        }}>
          <h3 style={{ marginTop: 0, color: '#212529' }}>📊 任务统计</h3>
          <div style={{ display: 'flex', gap: 20, flexWrap: 'wrap', color: '#212529' }}>
            <div>
              <strong>总计:</strong> {stats.total}
            </div>
            <div>
              💼 工作: {stats.byCategory.work}
            </div>
            <div>
              📚 学习: {stats.byCategory.study}
            </div>
            <div>
              🏠 生活: {stats.byCategory.life}
            </div>
            <div>
              📝 其他: {stats.byCategory.other}
            </div>
          </div>
          <div style={{ marginTop: 10, display: 'flex', gap: 20 }}>
            <div style={{ color: '#dc3545', fontWeight: 'bold' }}>
              🔴 高优: {stats.byPriority.high}
            </div>
            <div style={{ color: '#0d6efd', fontWeight: 'bold' }}>
              🔵 普通: {stats.byPriority.normal}
            </div>
            <div style={{ color: '#198754', fontWeight: 'bold' }}>
              🟢 低优: {stats.byPriority.low}
            </div>
          </div>
        </div>
      )}
      
      {/* 输入框 */}
      <div style={{ marginBottom: 20, padding: 15, background: 'rgba(255,255,255,0.95)', borderRadius: 8, boxShadow: '0 4px 12px rgba(0,0,0,0.15)' }}>
        <div style={{ marginBottom: 10 }}>
          <strong style={{ color: '#212529' }}>💡 试试这些：</strong>
          <div style={{ fontSize: 14, color: '#6c757d', marginTop: 5 }}>
            "紧急工作会议" / "明天买菜" / "学习React课程" / "有空看书"
          </div>
        </div>
        <input
          value={task}
          onChange={e => setTask(e.target.value)}
          onKeyPress={e => e.key === 'Enter' && addTodo()}
          placeholder="输入任务，AI会自动分类..."
          style={{ 
            padding: 10, 
            marginRight: 8, 
            width: '70%',
            fontSize: 16,
            border: '2px solid #ddd',
            borderRadius: 5
          }}
        />
        <button 
          onClick={addTodo} 
          style={{ 
            padding: '10px 20px',
            fontSize: 16,
            background: '#4caf50',
            color: 'white',
            border: 'none',
            borderRadius: 5,
            cursor: 'pointer'
          }}
        >
          ✨ 添加
        </button>
      </div>
      
      {/* 任务列表 */}
      <div style={{ padding: 15, background: 'rgba(255,255,255,0.95)', borderRadius: 8, boxShadow: '0 4px 12px rgba(0,0,0,0.15)' }}>
        <h3 style={{ marginTop: 0, color: '#212529' }}>📋 任务列表 ({todos.length})</h3>
        {todos.length === 0 ? (
          <p style={{ color: '#999', textAlign: 'center', padding: 40 }}>
            还没有任务，添加一个试试吧！
          </p>
        ) : (
          <ul style={{ listStyle: 'none', padding: 0 }}>
            {todos.map(t => {
              const categoryDisplay = getCategoryDisplay(t.category);
              const priorityDisplay = getPriorityDisplay(t.priority);
              
              return (
                <li key={t._id} style={{ 
                  marginBottom: 12, 
                  padding: 15, 
                  background: '#f8f9fa',
                  border: `3px solid ${priorityDisplay.color}`,
                  borderRadius: 8,
                  boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
                }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                    <span style={{ fontSize: 24 }}>{categoryDisplay.icon}</span>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontSize: 16, fontWeight: 'bold', marginBottom: 5, color: '#212529' }}>
                        {t.text}
                      </div>
                      <div style={{ fontSize: 13, color: '#495057' }}>
                        <span style={{ 
                          background: priorityDisplay.color,
                          color: 'white',
                          padding: '2px 8px',
                          borderRadius: 3,
                          marginRight: 8
                        }}>
                          {priorityDisplay.name}优先级
                        </span>
                        <span style={{ 
                          background: '#e0e0e0',
                          padding: '2px 8px',
                          borderRadius: 3,
                          marginRight: 8
                        }}>
                          {categoryDisplay.name}
                        </span>
                        {t.deadline && (
                          <span>
                            ⏰ {new Date(t.deadline).toLocaleDateString('zh-CN')}
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                </li>
              );
            })}
          </ul>
        )}
      </div>
      
      <div style={{ marginTop: 30, padding: 15, background: 'rgba(255,255,255,0.95)', borderRadius: 8, fontSize: 13, boxShadow: '0 2px 8px rgba(0,0,0,0.1)', color: '#212529' }}>
        <strong>🔧 技术说明：</strong>
        <ul style={{ margin: '5px 0', paddingLeft: 20 }}>
          <li>前端 → 后端A (智能分类) → 后端B (数据存储)</li>
          <li>后端A自动识别任务类型和优先级</li>
          <li>后端B负责MongoDB数据库操作</li>
        </ul>
      </div>
      </div>
    </div>
  );
}

export default App;

