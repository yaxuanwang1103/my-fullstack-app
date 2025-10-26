param(
  [string]$Region = 'us-east-2',
  [string]$Cluster = 'todoapp-cluster',
  [string[]]$Services = @('todoapp-backend-a'),
  [string[]]$Ports = @('3000','4000'),
  [string[]]$SecurityGroupIds = @(),
  [string[]]$SourceCidrs = @()
)

$ErrorActionPreference = 'Stop'

function Get-PublicIp {
  try {
    return (Invoke-RestMethod -UseBasicParsing -Uri 'https://checkip.amazonaws.com/').Trim()
  } catch {
    Write-Error '无法获取本机公网IP，手动用 -SecurityGroupId 与 -Ports 运行，或检查网络。'
    throw
  }
}

function Get-ServiceSecurityGroupIds {
  param([string]$Cluster,[string[]]$Services,[string]$Region)
  $result = @()
  foreach ($svcName in $Services) {
    $svc = aws ecs describe-services --cluster $Cluster --services $svcName --region $Region | ConvertFrom-Json
    $sgs = $svc.services[0].networkConfiguration.awsvpcConfiguration.securityGroups
    if ($sgs -and $sgs.Count -gt 0) { $result += $sgs }
  }
  if (-not $result -or $result.Count -eq 0) { throw "未能从服务获取安全组，请手动指定 -SecurityGroupIds" }
  return $result | Select-Object -Unique
}

if (-not $SecurityGroupIds -or $SecurityGroupIds.Count -eq 0) {
  # Normalize services input: support a single comma-separated string
  if ($Services.Count -eq 1 -and $Services[0] -match ',') {
    $Services = $Services[0].Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
  }
  Write-Host "查询服务安全组: $(($Services -join ', '))" -ForegroundColor Cyan
  $SecurityGroupIds = Get-ServiceSecurityGroupIds -Cluster $Cluster -Services $Services -Region $Region
}

if (-not $SourceCidrs -or $SourceCidrs.Count -eq 0) {
  $pubIp = Get-PublicIp
  Write-Host "当前公网IP: $pubIp" -ForegroundColor Yellow
  $SourceCidrs = @("$pubIp/32")
}
## Normalize ports (support comma-separated strings and trim)
$portList = @()
foreach ($p in $Ports) {
  if ($null -eq $p) { continue }
  $p.ToString().Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ } | ForEach-Object {
    if ($_ -notmatch '^[0-9]{1,5}$') { throw "无效端口: $_" }
    $pi = [int]$_
    if ($pi -lt 1 -or $pi -gt 65535) { throw "端口超出范围: $pi" }
    $portList += $pi
  }
}
$portList = $portList | Select-Object -Unique

Write-Host "安全组: $(($SecurityGroupIds -join ', '))，开放端口: $(($portList -join ', '))，来源: $(($SourceCidrs -join ', '))" -ForegroundColor Cyan

foreach ($sg in $SecurityGroupIds) {
  foreach ($p in $portList) {
    foreach ($cidr in $SourceCidrs) {
      try {
        aws ec2 authorize-security-group-ingress `
          --group-id $sg `
          --protocol tcp `
          --port $p `
          --cidr $cidr `
          --region $Region | Out-Null
        Write-Host "[$sg] 已放行 $p/tcp 给 $cidr" -ForegroundColor Green
      } catch {
        if ($_.Exception.Message -match 'InvalidPermission.Duplicate') {
          Write-Host "[$sg] 规则已存在: $p/tcp $cidr" -ForegroundColor DarkYellow
        } else {
          throw
        }
      }
    }
  }
}

Write-Host "完成。建议现在测试: curl.exe http://<后端A Public IP>:3000" -ForegroundColor Yellow
