# 列出所有 ECS 服务

$AWS_REGION = "us-east-2"
$CLUSTER = "todoapp-cluster"

Write-Host "🔍 列出集群中的所有服务..." -ForegroundColor Cyan
Write-Host ""

$services = aws ecs list-services --cluster $CLUSTER --region $AWS_REGION --output json | ConvertFrom-Json

if ($services.serviceArns.Count -eq 0) {
    Write-Host "❌ 集群中没有任何服务" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 建议：使用 AWS 控制台手动创建服务" -ForegroundColor Yellow
} else {
    Write-Host "✅ 找到 $($services.serviceArns.Count) 个服务:" -ForegroundColor Green
    Write-Host ""
    
    foreach ($serviceArn in $services.serviceArns) {
        $serviceName = $serviceArn.Split('/')[-1]
        Write-Host "   - $serviceName" -ForegroundColor White
        
        # 获取服务详情
        $serviceDetail = aws ecs describe-services --cluster $CLUSTER --services $serviceName --region $AWS_REGION --output json | ConvertFrom-Json
        $service = $serviceDetail.services[0]
        
        Write-Host "     状态: $($service.status)" -ForegroundColor Cyan
        Write-Host "     运行中: $($service.runningCount) / 期望: $($service.desiredCount)" -ForegroundColor Cyan
        Write-Host ""
    }
}
