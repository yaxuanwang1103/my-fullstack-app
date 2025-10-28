# 创建 ECS 服务脚本
# 注意：需要先配置 VPC、子网和安全组信息

$AWS_REGION = "us-east-2"
$CLUSTER = "todoapp-cluster"

# VPC 配置信息（已自动获取）
# 使用两个不同可用区的公有子网
$SUBNETS = "subnet-035db9235c973fe06,subnet-0561867f569f2e5d1"  # us-east-2b, us-east-2c
$SECURITY_GROUPS = "sg-09c939602a07f42d9"  # todoapp-ecs-sg

Write-Host "🚀 创建 ECS 服务..." -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  请先确认以下信息已正确配置：" -ForegroundColor Yellow
Write-Host "   - SUBNETS: $SUBNETS" -ForegroundColor Yellow
Write-Host "   - SECURITY_GROUPS: $SECURITY_GROUPS" -ForegroundColor Yellow
Write-Host ""

$continue = Read-Host "是否继续？(y/n)"
if ($continue -ne "y") {
    Write-Host "已取消" -ForegroundColor Red
    exit 0
}

# 创建 Backend A 服务
Write-Host "创建 Backend A 服务..." -ForegroundColor Yellow
aws ecs create-service `
    --cluster $CLUSTER `
    --service-name todoapp-backend-a `
    --task-definition todoapp-backend-a:6 `
    --desired-count 1 `
    --launch-type FARGATE `
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNETS],securityGroups=[$SECURITY_GROUPS],assignPublicIp=ENABLED}" `
    --region $AWS_REGION

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Backend A 服务创建成功" -ForegroundColor Green
} else {
    Write-Host "❌ Backend A 服务创建失败" -ForegroundColor Red
}

Write-Host ""

# 创建 Backend B 服务
Write-Host "创建 Backend B 服务..." -ForegroundColor Yellow
aws ecs create-service `
    --cluster $CLUSTER `
    --service-name todoapp-backend-b `
    --task-definition todoapp-backend-b:4 `
    --desired-count 1 `
    --launch-type FARGATE `
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNETS],securityGroups=[$SECURITY_GROUPS],assignPublicIp=ENABLED}" `
    --region $AWS_REGION

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Backend B 服务创建成功" -ForegroundColor Green
} else {
    Write-Host "❌ Backend B 服务创建失败" -ForegroundColor Red
}

Write-Host ""

# 创建 Frontend 服务
Write-Host "创建 Frontend 服务..." -ForegroundColor Yellow
aws ecs create-service `
    --cluster $CLUSTER `
    --service-name todoapp-frontend `
    --task-definition todoapp-frontend:5 `
    --desired-count 1 `
    --launch-type FARGATE `
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNETS],securityGroups=[$SECURITY_GROUPS],assignPublicIp=ENABLED}" `
    --region $AWS_REGION

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Frontend 服务创建成功" -ForegroundColor Green
} else {
    Write-Host "❌ Frontend 服务创建失败" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 服务创建完成！" -ForegroundColor Cyan
Write-Host ""
Write-Host "运行 .\verify-ecs-resources.ps1 验证服务状态" -ForegroundColor Yellow
