# ECS 资源验证脚本
# 用于检查 ECS 集群、服务和 Task Definition 是否存在

$AWS_REGION = "us-east-2"  # 修改为你的区域
$CLUSTER = "todoapp-cluster"

Write-Host "🔍 验证 AWS ECS 资源..." -ForegroundColor Cyan
Write-Host ""

# 检查 AWS CLI 是否安装
Write-Host "检查 AWS CLI..." -ForegroundColor Yellow
try {
    $awsVersion = aws --version
    Write-Host "✅ AWS CLI 已安装: $awsVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS CLI 未安装，请先安装 AWS CLI" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 检查集群
Write-Host "检查 ECS 集群..." -ForegroundColor Yellow
try {
    $cluster = aws ecs describe-clusters --clusters $CLUSTER --region $AWS_REGION --query 'clusters[0].[clusterName,status]' --output text 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 集群存在: $cluster" -ForegroundColor Green
    } else {
        Write-Host "❌ 集群不存在或无法访问" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ 检查集群失败: $_" -ForegroundColor Red
}

Write-Host ""

# 检查服务
$services = @("todoapp-backend-a", "todoapp-backend-b", "todoapp-frontend")

Write-Host "检查 ECS 服务..." -ForegroundColor Yellow
foreach ($service in $services) {
    try {
        $serviceInfo = aws ecs describe-services --cluster $CLUSTER --services $service --region $AWS_REGION --query 'services[0].[serviceName,status,runningCount,desiredCount]' --output text 2>&1
        if ($LASTEXITCODE -eq 0 -and $serviceInfo -notmatch "MISSING") {
            Write-Host "✅ 服务 $service : $serviceInfo" -ForegroundColor Green
        } else {
            Write-Host "❌ 服务 $service 不存在" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ 检查服务 $service 失败" -ForegroundColor Red
    }
}

Write-Host ""

# 检查 Task Definitions
$taskDefs = @(
    @{Name="todoapp-backend-a"; Version=6},
    @{Name="todoapp-backend-b"; Version=4},
    @{Name="todoapp-frontend"; Version=5}
)

Write-Host "检查 Task Definitions..." -ForegroundColor Yellow
foreach ($taskDef in $taskDefs) {
    $taskDefArn = "$($taskDef.Name):$($taskDef.Version)"
    try {
        $taskDefInfo = aws ecs describe-task-definition --task-definition $taskDefArn --region $AWS_REGION --query 'taskDefinition.[family,revision,status]' --output text 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Task Definition $taskDefArn : $taskDefInfo" -ForegroundColor Green
        } else {
            Write-Host "❌ Task Definition $taskDefArn 不存在" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ 检查 Task Definition $taskDefArn 失败" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🎯 验证完成！" -ForegroundColor Cyan
Write-Host ""
Write-Host "如果看到 ❌，请修复对应的问题后再部署" -ForegroundColor Yellow
