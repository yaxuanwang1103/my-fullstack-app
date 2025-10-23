import 'dotenv/config';
import express from 'express';
import axios from 'axios';
import cors from 'cors';

const app = express();
app.use(cors());
app.use(express.json());

const BACKEND_B_URL = 'http://localhost:4000';

// 智能分析任务函数
function analyzeTask(task) {
  const text = task.toLowerCase();
  
  // 分析类别
  let category = 'other';
  if (text.includes('工作') || text.includes('会议') || text.includes('项目') || text.includes('开发')) {
    category = 'work';
  } else if (text.includes('学习') || text.includes('读书') || text.includes('课程') || text.includes('作业')) {
    category = 'study';
  } else if (text.includes('买') || text.includes('吃') || text.includes('运动') || text.includes('健身')) {
    category = 'life';
  }
  
  // 分析优先级
  let priority = 'normal';
  if (text.includes('紧急') || text.includes('重要') || text.includes('马上') || text.includes('立刻')) {
    priority = 'high';
  } else if (text.includes('有空') || text.includes('可以') || text.includes('随便')) {
    priority = 'low';
  }
  
  // 提取截止日期
  let deadline = null;
  if (text.includes('今天')) {
    deadline = new Date();
  } else if (text.includes('明天')) {
    deadline = new Date(Date.now() + 86400000);
  } else if (text.includes('下周')) {
    deadline = new Date(Date.now() + 7 * 86400000);
  }
  
  return { category, priority, deadline };
}

// 创建任务 - 智能处理
app.post('/api/messages', async (req, res) => {
  try {
    const { author, text } = req.body;
    
    console.log('📝 后端A收到任务:', text);
    
    // 步骤1：智能分析
    const analysis = analyzeTask(text);
    console.log('🤖 分析结果:', analysis);
    
    // 步骤2：构建增强数据
    const enhancedData = {
      author: author || '匿名用户',
      text,
      category: analysis.category,
      priority: analysis.priority,
      deadline: analysis.deadline,
      tags: [analysis.category, analysis.priority],
      processedBy: 'AI-Backend-A',
      processedAt: new Date()
    };
    
    // 步骤3：发送给后端B存储
    console.log('📤 转发给后端B...');
    const response = await axios.post(`${BACKEND_B_URL}/api/messages`, enhancedData);
    
    console.log('✅ 后端B已保存');
    
    // 翻译类别和优先级
    const categoryNames = {
      work: '工作',
      study: '学习',
      life: '生活',
      other: '其他'
    };
    const priorityNames = {
      high: '高优先级',
      normal: '普通',
      low: '低优先级'
    };
    
    res.json({
      success: true,
      message: `✅ 任务已分类为【${categoryNames[analysis.category]}】，优先级【${priorityNames[analysis.priority]}】`,
      data: response.data
    });
    
  } catch (error) {
    console.error('❌ 错误:', error.message);
    res.status(500).json({ error: '处理失败', details: error.message });
  }
});

// 获取任务 - 添加统计信息
app.get('/api/messages', async (req, res) => {
  try {
    console.log('📥 后端A收到获取请求');
    
    // 从后端B获取数据
    const response = await axios.get(`${BACKEND_B_URL}/api/messages`);
    const todos = response.data;
    
    console.log(`📊 获取到 ${todos.length} 条数据`);
    
    // 后端A添加统计分析
    const stats = {
      total: todos.length,
      byCategory: {
        work: todos.filter(t => t.category === 'work').length,
        study: todos.filter(t => t.category === 'study').length,
        life: todos.filter(t => t.category === 'life').length,
        other: todos.filter(t => t.category === 'other').length
      },
      byPriority: {
        high: todos.filter(t => t.priority === 'high').length,
        normal: todos.filter(t => t.priority === 'normal').length,
        low: todos.filter(t => t.priority === 'low').length
      }
    };
    
    res.json({
      items: todos,
      stats: stats,
      processedBy: 'Backend-A',
      timestamp: new Date()
    });
    
  } catch (error) {
    console.error('❌ 错误:', error.message);
    res.status(500).json({ error: '获取失败', details: error.message });
  }
});

// 健康检查
app.get('/health', async (req, res) => {
  try {
    const backendB = await axios.get(`${BACKEND_B_URL}/health`);
    res.json({
      backendA: 'OK',
      backendB: backendB.data,
      collaboration: 'Active ✅'
    });
  } catch (error) {
    res.json({ 
      backendA: 'OK', 
      backendB: 'ERROR ❌',
      error: error.message 
    });
  }
});

const PORT = 3000;
app.listen(PORT, () => console.log(`🤖 后端A (智能分类) 运行在 http://localhost:${PORT}`));