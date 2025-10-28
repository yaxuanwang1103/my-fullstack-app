# 创建 ECS 服务脚本（修复版）

$AWS_REGION = "us-east-2"
$CLUSTER = "todoapp-cluster"

# VPC 配置信息
$SUBNET1 = "subnet-035db9235c973fe06"  # us-east-2b
$SUBNET2 = "subnet-0561867f569f2e5d1"  # us-east-2c
$SECURITY_GROUP = "sg-09c939602a07f42d9"  # todoapp-ecs-sg

Write-Host "🚀 创建 ECS 服务..." -ForegroundColor Cyan
Write-Host ""
Write-Host "配置信息:" -ForegroundColor Yellow
Write-Host "   - Region: $AWS_REGION" -ForegroundColor White
Write-Host "   - Cluster: $CLUSTER" -ForegroundColor White
Write-Host "   - Subnets: $SUBNET1, $SUBNET2" -ForegroundColor White
Write-Host "   - Security Group: $SECURITY_GROUP" -ForegroundColor White
Write-Host ""

$continue = Read-Host "是否继续？(y/n)"
if ($continue -ne "y") {
    Write-Host "已取消" -ForegroundColor Red
    exit 0
}

Write-Host ""

# 创建 Backend A 服务
Write-Host "创建 Backend A 服务..." -ForegroundColor Yellow
aws ecs create-service `
    --cluster $CLUSTER `
    --service-name todoapp-backend-a `
    --task-definition todoapp-backend-a:6 `
    --desired-count 1 `
    --launch-type FARGATE `
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET1,$SUBNET2],securityGroups=[$SECURITY_GROUP],assignPublicIp=ENABLED}" `
    --region $AWS_REGION

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Backend A 服务创建成功" -ForegroundColor Green
} else {
    Write-Host "❌ Backend A 服务创建失败，错误码: $LASTEXITCODE" -ForegroundColor Red
    Write-Host "提示: 如果服务已存在，可以忽略此错误" -ForegroundColor Yellow
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
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET1,$SUBNET2],securityGroups=[$SECURITY_GROUP],assignPublicIp=ENABLED}" `
    --region $AWS_REGION

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Backend B 服务创建成功" -ForegroundColor Green
} else {
    Write-Host "❌ Backend B 服务创建失败，错误码: $LASTEXITCODE" -ForegroundColor Red
    Write-Host "提示: 如果服务已存在，可以忽略此错误" -ForegroundColor Yellow
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
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET1,$SUBNET2],securityGroups=[$SECURITY_GROUP],assignPublicIp=ENABLED}" `
    --region $AWS_REGION

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Frontend 服务创建成功" -ForegroundColor Green
} else {
    Write-Host "❌ Frontend 服务创建失败，错误码: $LASTEXITCODE" -ForegroundColor Red
    Write-Host "提示: 如果服务已存在，可以忽略此错误" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎯 服务创建流程完成！" -ForegroundColor Cyan
Write-Host ""
Write-Host "等待 30 秒让服务启动..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "运行验证脚本检查服务状态..." -ForegroundColor Cyan
& ".\verify-ecs-resources.ps1"
