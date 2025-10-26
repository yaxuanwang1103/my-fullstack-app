param(
  [string]$Region = 'us-east-2',
  [string]$Cluster = 'todoapp-cluster',
  [string[]]$Services = @('todoapp-frontend','todoapp-backend-a','todoapp-backend-b'),
  [string[]]$Ports = @('80','3000','4000'),
  [string[]]$SecurityGroupIds = @(),
  [string[]]$SourceCidrs = @()
)

$ErrorActionPreference = 'Stop'

function Get-PublicIp {
  (Invoke-RestMethod -UseBasicParsing -Uri 'https://checkip.amazonaws.com/').Trim()
}

function Get-ServiceSecurityGroupIds {
  param([string]$Cluster,[string[]]$Services,[string]$Region)
  $result = @()
  foreach ($svcName in $Services) {
    $svc = aws ecs describe-services --cluster $Cluster --services $svcName --region $Region | ConvertFrom-Json
    $sgs = $svc.services[0].networkConfiguration.awsvpcConfiguration.securityGroups
    if ($sgs) { $result += $sgs }
  }
  $result | Select-Object -Unique
}

# Normalize inputs
if ($Services.Count -eq 1 -and $Services[0] -match ',') {
  $Services = $Services[0].Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}

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

if (-not $SecurityGroupIds -or $SecurityGroupIds.Count -eq 0) {
  Write-Host "查询服务安全组: $(($Services -join ', '))" -ForegroundColor Cyan
  $SecurityGroupIds = Get-ServiceSecurityGroupIds -Cluster $Cluster -Services $Services -Region $Region
  if (-not $SecurityGroupIds -or $SecurityGroupIds.Count -eq 0) { throw '未找到任何安全组' }
}

if (-not $SourceCidrs -or $SourceCidrs.Count -eq 0) {
  $ip = Get-PublicIp
  $SourceCidrs = @("$ip/32")
}

Write-Host "将端口收紧到: $(($SourceCidrs -join ', '))" -ForegroundColor Yellow
Write-Host "目标安全组: $(($SecurityGroupIds -join ', '))；端口: $(($portList -join ', '))" -ForegroundColor Cyan

foreach ($sg in $SecurityGroupIds) {
  $desc = aws ec2 describe-security-groups --group-ids $sg --region $Region | ConvertFrom-Json
  $perm = $desc.SecurityGroups[0].IpPermissions
  foreach ($p in $portList) {
    # 找到需要撤销的 CIDR（例如 0.0.0.0/0 或任何不在白名单中的）
    $toRevoke = @()
    foreach ($rule in $perm) {
      if ($rule.IpProtocol -eq 'tcp' -and $rule.FromPort -eq $p -and $rule.ToPort -eq $p) {
        foreach ($r in $rule.IpRanges) {
          $cidr = $r.CidrIp
          if ($SourceCidrs -notcontains $cidr) { $toRevoke += $cidr }
        }
      }
    }
    $toRevoke = $toRevoke | Select-Object -Unique
    foreach ($cidr in $toRevoke) {
      try {
        aws ec2 revoke-security-group-ingress --group-id $sg --protocol tcp --port $p --cidr $cidr --region $Region | Out-Null
        Write-Host "[$sg] 已撤销 $cidr 对 $p/tcp 的访问" -ForegroundColor DarkYellow
      } catch {
        Write-Host "[$sg] 撤销失败或不存在: $cidr $p/tcp → $($_.Exception.Message)" -ForegroundColor Red
      }
    }
    foreach ($cidr in $SourceCidrs) {
      try {
        aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port $p --cidr $cidr --region $Region | Out-Null
        Write-Host "[$sg] 已放行 $cidr 访问 $p/tcp" -ForegroundColor Green
      } catch {
        if ($_.Exception.Message -match 'InvalidPermission.Duplicate') {
          Write-Host "[$sg] 放行规则已存在: $cidr $p/tcp" -ForegroundColor Green
        } else {
          throw
        }
      }
    }
  }
}

Write-Host '完成。现在仅允许上述来源访问这些端口。' -ForegroundColor Yellow

