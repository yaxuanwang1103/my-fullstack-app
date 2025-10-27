// 简单的测试文件
// 运行: node test.js

console.log('🧪 开始测试后端B...');

// 测试1: 检查必要的依赖
console.log('\n📦 检查依赖...');
try {
  await import('express');
  console.log('✅ express 已安装');
} catch (e) {
  console.log('❌ express 未安装');
  process.exit(1);
}

try {
  await import('pg');
  console.log('✅ pg 已安装');
} catch (e) {
  console.log('❌ pg 未安装');
  process.exit(1);
}

try {
  await import('cors');
  console.log('✅ cors 已安装');
} catch (e) {
  console.log('❌ cors 未安装');
  process.exit(1);
}

// 测试2: 检查环境变量
console.log('\n🔧 检查环境变量...');
const requiredEnvVars = [
  'POSTGRES_HOST',
  'POSTGRES_PORT',
  'POSTGRES_DB',
  'POSTGRES_USER',
  'POSTGRES_PASSWORD'
];

let envOk = true;
requiredEnvVars.forEach(varName => {
  if (process.env[varName]) {
    console.log(`✅ ${varName} 已设置`);
  } else {
    console.log(`⚠️  ${varName} 未设置（使用默认值）`);
  }
});

// 测试3: 检查文件结构
console.log('\n📁 检查文件结构...');
import { existsSync } from 'fs';

const requiredFiles = [
  './server.js',
  './db.js',
  './routes/messages.js'
];

requiredFiles.forEach(file => {
  if (existsSync(file)) {
    console.log(`✅ ${file} 存在`);
  } else {
    console.log(`❌ ${file} 不存在`);
    envOk = false;
  }
});

console.log('\n📊 测试结果:');
if (envOk) {
  console.log('🎉 所有测试通过！');
  process.exit(0);
} else {
  console.log('❌ 部分测试失败');
  process.exit(1);
}
