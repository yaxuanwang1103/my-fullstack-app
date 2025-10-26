param(
  [string]$Region = 'us-east-2',
  [string]$Cluster = 'todoapp-cluster',
  [string]$FrontendService = 'todoapp-frontend',
  [string]$BackendAService = 'todoapp-backend-a',
  [string]$BackendBService = 'todoapp-backend-b'
)

$ErrorActionPreference = 'Stop'

function Register-And-Update {
  param(
    [Parameter(Mandatory=$true)] [string]$JsonPath,
    [Parameter(Mandatory=$true)] [string]$ServiceName
  )

  Write-Host "Registering task: $JsonPath" -ForegroundColor Cyan
  $td = aws ecs register-task-definition --cli-input-json "file://$JsonPath" --region $Region | ConvertFrom-Json
  $arn = $td.taskDefinition.taskDefinitionArn
  Write-Host "New taskDefinitionArn: $arn" -ForegroundColor Green

  Write-Host "Updating service: $ServiceName" -ForegroundColor Cyan
  aws ecs update-service --cluster $Cluster --service $ServiceName --task-definition $arn --region $Region | Out-Null
  Write-Host "Service updated: $ServiceName" -ForegroundColor Green
}

# Resolve repo root (this script is in scripts/)
$root = Split-Path -Parent $PSScriptRoot

$frontendJson = Join-Path $root 'task-definition-frontend.json'
$backendAJson = Join-Path $root 'task-definition-backend-a.json'
$backendBJson = Join-Path $root 'task-definition-backend-b.json'

Register-And-Update -JsonPath $frontendJson -ServiceName $FrontendService
Register-And-Update -JsonPath $backendAJson -ServiceName $BackendAService
Register-And-Update -JsonPath $backendBJson -ServiceName $BackendBService

Write-Host "All done (frontend, backend-a, backend-b)." -ForegroundColor Yellow
