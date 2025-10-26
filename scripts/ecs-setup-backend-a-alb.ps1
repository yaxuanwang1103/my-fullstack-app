param(
  [string]$Region = 'us-east-2',
  [string]$VpcId = 'vpc-05f7d779e95869e07',
  [string[]]$Subnets = @('subnet-035db9235c973fe06','subnet-0561867f569f2e5d1','subnet-029696762e6a77c6c'),
  [string]$ServiceSecurityGroupId = 'sg-09c939602a07f42d9',
  [string]$AlbName = 'todoapp-backend-a-alb',
  [string]$AlbSecurityGroupName = 'todoapp-backend-a-alb-sg',
  [string]$TargetGroupName = 'todoapp-backend-a-tg',
  [string]$Cluster = 'todoapp-cluster',
  [string]$ServiceName = 'todoapp-backend-a',
  [string]$ContainerName = 'backend-a',
  [int]$ContainerPort = 3000,
  [string]$HealthPath = '/health'
)

$ErrorActionPreference = 'Stop'

function Get-ExistingAlb {
  param([string]$Name)
  $lbs = aws elbv2 describe-load-balancers --region $Region | ConvertFrom-Json
  return $lbs.LoadBalancers | Where-Object { $_.LoadBalancerName -eq $Name }
}

function Get-ExistingTg {
  param([string]$Name)
  $tgs = aws elbv2 describe-target-groups --region $Region | ConvertFrom-Json
  return $tgs.TargetGroups | Where-Object { $_.TargetGroupName -eq $Name }
}

function Ensure-AlbSecurityGroup {
  param([string]$Name)
  $found = aws ec2 describe-security-groups --filters Name=group-name,Values=$Name Name=vpc-id,Values=$VpcId --region $Region | ConvertFrom-Json
  if ($found.SecurityGroups.Count -gt 0) { return $found.SecurityGroups[0].GroupId }
  $sg = aws ec2 create-security-group --group-name $Name --description 'ALB SG for backend-a' --vpc-id $VpcId --region $Region | ConvertFrom-Json
  $sgId = $sg.GroupId
  # Allow HTTP 80 from anywhere
  aws ec2 authorize-security-group-ingress --group-id $sgId --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $Region | Out-Null
  return $sgId
}

function Ensure-Alb {
  param([string]$Name,[string]$SgId)
  $existing = Get-ExistingAlb -Name $Name
  if ($existing) { return $existing.LoadBalancerArn }
  $cmd = @(
    'elbv2','create-load-balancer',
    '--name', $Name,
    '--scheme','internet-facing',
    '--type','application',
    '--ip-address-type','ipv4',
    '--region',$Region,
    '--security-groups',$SgId,
    '--subnets'
  ) + $Subnets
  $alb = aws @cmd | ConvertFrom-Json
  return $alb.LoadBalancers[0].LoadBalancerArn
}

function Ensure-TargetGroup {
  param([string]$Name)
  $existing = Get-ExistingTg -Name $Name
  if ($existing) { return $existing.TargetGroupArn }
  $tg = aws elbv2 create-target-group `
    --name $Name `
    --protocol HTTP `
    --port $ContainerPort `
    --vpc-id $VpcId `
    --target-type ip `
    --health-check-protocol HTTP `
    --health-check-path $HealthPath `
    --health-check-interval-seconds 15 `
    --health-check-timeout-seconds 5 `
    --healthy-threshold-count 2 `
    --unhealthy-threshold-count 2 `
    --matcher HttpCode=200 `
    --region $Region | ConvertFrom-Json
  return $tg.TargetGroups[0].TargetGroupArn
}

function Ensure-Listener {
  param([string]$AlbArn,[string]$TgArn)
  $ls = aws elbv2 describe-listeners --load-balancer-arn $AlbArn --region $Region | ConvertFrom-Json
  $existing80 = $ls.Listeners | Where-Object { $_.Port -eq 80 }
  if ($existing80) {
    # Update default action to forward to our TG
    $rules = aws elbv2 describe-rules --listener-arn $existing80.ListenerArn --region $Region | ConvertFrom-Json
    # Set default action
    aws elbv2 modify-listener --listener-arn $existing80.ListenerArn --default-actions Type=forward,TargetGroupArn=$TgArn --region $Region | Out-Null
    return $existing80.ListenerArn
  }
  $l = aws elbv2 create-listener `
    --load-balancer-arn $AlbArn `
    --protocol HTTP `
    --port 80 `
    --default-actions Type=forward,TargetGroupArn=$TgArn `
    --region $Region | ConvertFrom-Json
  return $l.Listeners[0].ListenerArn
}

function Allow-AlbToService {
  param([string]$AlbSg,[string]$SvcSg)
  try {
    aws ec2 authorize-security-group-ingress `
      --group-id $SvcSg `
      --protocol tcp `
      --port $ContainerPort `
      --source-group $AlbSg `
      --region $Region | Out-Null
  } catch {
    if ($_.Exception.Message -notmatch 'InvalidPermission.Duplicate') { throw }
  }
}

function Attach-Lb-To-Service {
  param([string]$TgArn)
  # Update ECS service to use ALB
  aws ecs update-service `
    --cluster $Cluster `
    --service $ServiceName `
    --load-balancers targetGroupArn=$TgArn,containerName=$ContainerName,containerPort=$ContainerPort `
    --health-check-grace-period-seconds 30 `
    --region $Region | Out-Null
}

Write-Host 'Creating/ensuring ALB, TG, Listener...' -ForegroundColor Cyan
$albSgId = Ensure-AlbSecurityGroup -Name $AlbSecurityGroupName
$albArn  = Ensure-Alb -Name $AlbName -SgId $albSgId
$tgArn   = Ensure-TargetGroup -Name $TargetGroupName
$listenerArn = Ensure-Listener -AlbArn $albArn -TgArn $tgArn

Write-Host "ALB: $albArn" -ForegroundColor Green
Write-Host "TG:  $tgArn" -ForegroundColor Green
Write-Host "Listener: $listenerArn" -ForegroundColor Green

Write-Host 'Allowing ALB SG to reach service SG...' -ForegroundColor Cyan
Allow-AlbToService -AlbSg $albSgId -SvcSg $ServiceSecurityGroupId

Write-Host 'Attaching ALB to ECS service...' -ForegroundColor Cyan
Attach-Lb-To-Service -TgArn $tgArn

# Output ALB DNS
$albDesc = aws elbv2 describe-load-balancers --load-balancer-arns $albArn --region $Region | ConvertFrom-Json
$dns = $albDesc.LoadBalancers[0].DNSName
Write-Host "Done. Backend-A ALB DNS: http://$dns" -ForegroundColor Yellow

