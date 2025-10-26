param(
  [Parameter(Mandatory=$true)] [string]$HostedZoneId,
  [Parameter(Mandatory=$true)] [string]$RecordName,
  [string]$Region = 'us-east-2',
  [string]$TargetIp = '',
  [string]$Cluster = '',
  [string]$ServiceName = '',
  [int]$Ttl = 60
)

$ErrorActionPreference = 'Stop'

function Get-EcsServicePublicIp {
  param([string]$Cluster,[string]$ServiceName,[string]$Region)
  if (-not $Cluster -or -not $ServiceName) { throw 'Cluster 和 ServiceName 不能为空，或直接提供 -TargetIp' }
  $taskArn = aws ecs list-tasks --cluster $Cluster --service-name $ServiceName --desired-status RUNNING --region $Region --query 'taskArns[0]' --output text
  if (-not $taskArn -or $taskArn -eq 'None') { throw "未找到正在运行的任务: $ServiceName" }
  $ip = aws ecs describe-tasks --cluster $Cluster --tasks $taskArn --region $Region --query "tasks[0].attachments[0].details[?name=='publicIPv4Address'].value" --output text
  if (-not $ip -or $ip -eq 'None') { throw '该任务没有 Public IP（可能 assignPublicIp 未启用或在私有子网）' }
  return $ip
}

if (-not $TargetIp) {
  $TargetIp = Get-EcsServicePublicIp -Cluster $Cluster -ServiceName $ServiceName -Region $Region
}

Write-Host "将 $RecordName 指向 $TargetIp (TTL=$Ttl)" -ForegroundColor Cyan

$changeBatch = @{
  Comment = "UPSERT by script"
  Changes = @(@{
      Action = 'UPSERT'
      ResourceRecordSet = @{
        Name = $RecordName
        Type = 'A'
        TTL = $Ttl
        ResourceRecords = @(@{ Value = $TargetIp })
      }
    })
} | ConvertTo-Json -Depth 6

$tmp = New-TemporaryFile
Set-Content -Path $tmp -Value $changeBatch -Encoding ascii

aws route53 change-resource-record-sets `
  --hosted-zone-id $HostedZoneId `
  --change-batch file://$tmp | Out-Null

Remove-Item $tmp -ErrorAction SilentlyContinue

Write-Host "已提交变更至 Route 53。DNS 生效取决于 TTL 与缓存。" -ForegroundColor Green

