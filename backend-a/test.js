// 简单的测试文件
// 运行: node test.js

console.log('🧪 开始测试后端A...');

// 测试1: 智能分析函数
function analyzeTask(task) {
  const text = task.toLowerCase();
  
  let category = 'other';
  if (text.includes('工作') || text.includes('会议') || text.includes('项目') || text.includes('开发')) {
    category = 'work';
  } else if (text.includes('学习') || text.includes('读书') || text.includes('课程') || text.includes('作业')) {
    category = 'study';
  } else if (text.includes('买') || text.includes('吃') || text.includes('运动') || text.includes('健身')) {
    category = 'life';
  }
  
  let priority = 'normal';
  if (text.includes('紧急') || text.includes('重要') || text.includes('马上') || text.includes('立刻')) {
    priority = 'high';
  } else if (text.includes('有空') || text.includes('可以') || text.includes('随便')) {
    priority = 'low';
  }
  
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

// 测试用例
const testCases = [
  { input: '紧急工作会议', expected: { category: 'work', priority: 'high' } },
  { input: '学习React课程', expected: { category: 'study', priority: 'normal' } },
  { input: '明天买菜', expected: { category: 'life', priority: 'normal' } },
  { input: '有空读书', expected: { category: 'other', priority: 'low' } },
];

let passed = 0;
let failed = 0;

testCases.forEach((test, index) => {
  const result = analyzeTask(test.input);
  const categoryMatch = result.category === test.expected.category;
  const priorityMatch = result.priority === test.expected.priority;
  
  if (categoryMatch && priorityMatch) {
    console.log(`✅ 测试 ${index + 1} 通过: "${test.input}"`);
    passed++;
  } else {
    console.log(`❌ 测试 ${index + 1} 失败: "${test.input}"`);
    console.log(`   期望: ${JSON.stringify(test.expected)}`);
    console.log(`   实际: ${JSON.stringify({ category: result.category, priority: result.priority })}`);
    failed++;
  }
});

console.log('\n📊 测试结果:');
console.log(`   通过: ${passed}`);
console.log(`   失败: ${failed}`);
console.log(`   总计: ${testCases.length}`);

if (failed === 0) {
  console.log('\n🎉 所有测试通过！');
  process.exit(0);
} else {
  console.log('\n❌ 部分测试失败');
  process.exit(1);
}
