# 获取 VPC 配置信息脚本

$AWS_REGION = "us-east-2"

Write-Host "🔍 获取 VPC 配置信息..." -ForegroundColor Cyan
Write-Host ""

# 获取子网信息
Write-Host "📍 可用子网列表:" -ForegroundColor Yellow
$subnets = aws ec2 describe-subnets --region $AWS_REGION --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,MapPublicIpOnLaunch]' --output text

if ($LASTEXITCODE -eq 0) {
    $subnets | ForEach-Object {
        Write-Host $_ -ForegroundColor White
    }
} else {
    Write-Host "❌ 获取子网信息失败" -ForegroundColor Red
}

Write-Host ""

# 获取安全组信息
Write-Host "🔒 安全组列表:" -ForegroundColor Yellow
$securityGroups = aws ec2 describe-security-groups --region $AWS_REGION --query 'SecurityGroups[*].[GroupId,GroupName,Description]' --output text

if ($LASTEXITCODE -eq 0) {
    $securityGroups | ForEach-Object {
        Write-Host $_ -ForegroundColor White
    }
} else {
    Write-Host "❌ 获取安全组信息失败" -ForegroundColor Red
}

Write-Host ""
Write-Host "💡 提示:" -ForegroundColor Cyan
Write-Host "   1. 选择 2 个不同可用区的子网（建议选择 MapPublicIpOnLaunch=True 的公有子网）" -ForegroundColor White
Write-Host "   2. 选择一个允许必要端口的安全组（需要开放 3000, 4000, 80 端口）" -ForegroundColor White
Write-Host ""
