# 自动更新前端配置并重新部署到 S3
param(
    [string]$BackendIP
)

if (-not $BackendIP) {
    Write-Host "正在获取 Backend-A 的 IP 地址..." -ForegroundColor Cyan
    
    # 获取任务
    $tasks = aws ecs list-tasks --cluster todoapp-cluster --service-name todoapp-backend-a --region us-east-2 | ConvertFrom-Json
    
    if ($tasks.taskArns.Count -eq 0) {
        Write-Error "未找到运行中的 backend-a 任务"
        exit 1
    }
    
    # 获取网络接口
    $taskArn = $tasks.taskArns[0]
    $eni = aws ecs describe-tasks --cluster todoapp-cluster --tasks $taskArn --region us-east-2 | ConvertFrom-Json | 
        Select-Object -ExpandProperty tasks | 
        Select-Object -ExpandProperty attachments | 
        Select-Object -ExpandProperty details | 
        Where-Object { $_.name -eq "networkInterfaceId" } | 
        Select-Object -ExpandProperty value
    
    # 获取公网 IP
    $BackendIP = aws ec2 describe-network-interfaces --network-interface-ids $eni --region us-east-2 | ConvertFrom-Json | 
        Select-Object -ExpandProperty NetworkInterfaces | 
        Select-Object -ExpandProperty Association | 
        Select-Object -ExpandProperty PublicIp
    
    Write-Host "Backend-A IP: $BackendIP" -ForegroundColor Green
}

# 更新 .env.production
$envFile = "frontend\.env.production"
$newContent = "VITE_API_URL=http://${BackendIP}:3000"
Set-Content -Path $envFile -Value $newContent
Write-Host "已更新 $envFile" -ForegroundColor Green

# 构建前端
Write-Host "`n正在构建前端..." -ForegroundColor Cyan
Set-Location frontend
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Error "前端构建失败"
    exit 1
}

# 上传到 S3
Write-Host "`n正在上传到 S3..." -ForegroundColor Cyan
aws s3 sync dist/ s3://sd-todoapp-bucket/ --delete

Write-Host "`n✅ 部署完成！" -ForegroundColor Green
Write-Host "前端地址: http://sd-todoapp-bucket.s3-website.us-east-2.amazonaws.com" -ForegroundColor Yellow
Write-Host "后端地址: http://${BackendIP}:3000" -ForegroundColor Yellow
Write-Host "`n测试后端连接:" -ForegroundColor Cyan
curl.exe "http://${BackendIP}:3000/health"
