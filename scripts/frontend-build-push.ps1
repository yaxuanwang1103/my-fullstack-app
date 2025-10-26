param(
  [string]$Region = 'us-east-2',
  [string]$AccountId = '982455488619',
  [string]$RepoName = 'todoapp-frontend',
  [string]$ImageTag = 'latest',
  [string]$ViteApiUrl = 'http://52.14.112.41:3000',
  [switch]$SkipLogin
)

$ErrorActionPreference = 'Stop'

$ecr = "$AccountId.dkr.ecr.$Region.amazonaws.com"
$localTag = "${RepoName}:$ImageTag"
$repoUri = "${ecr}/${RepoName}:$ImageTag"

aws sts get-caller-identity --region $Region | Out-Null
try {
  aws ecr describe-repositories --repository-names $RepoName --region $Region | Out-Null
} catch {
  Write-Host "ECR repo not found. Creating: $RepoName" -ForegroundColor Yellow
  aws ecr create-repository --repository-name $RepoName --region $Region --image-scanning-configuration scanOnPush=true --encryption-configuration encryptionType=AES256 | Out-Null
}

if (-not $SkipLogin) {
  Write-Host "Logging into ECR: $ecr" -ForegroundColor Cyan
  $token = aws ecr get-login-password --region $Region
  docker login --username AWS --password $token $ecr
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Direct login failed, retrying with --password-stdin (PowerShell may have pipe issues)..." -ForegroundColor Yellow
    aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $ecr
    if ($LASTEXITCODE -ne 0) {
      throw "Docker login to ECR failed. 可使用 -SkipLogin 跳过（已在 CMD 成功登录的情况下），或在当前会话先手动登录。"
    }
  }
} else {
  Write-Host "SkipLogin 指定，跳过 docker login。" -ForegroundColor Yellow
}

Write-Host "Building frontend image with VITE_API_URL=$ViteApiUrl" -ForegroundColor Cyan
docker build `
  -f ./frontend/Dockerfile `
  --build-arg VITE_API_URL=$ViteApiUrl `
  -t "$localTag" `
  ./frontend | Out-Null

docker tag "$localTag" "$repoUri"

Write-Host "Pushing image: $repoUri" -ForegroundColor Cyan
docker push $repoUri
if ($LASTEXITCODE -ne 0) { throw "Docker push failed for $repoUri" }

Write-Host "Done. Pushed $repoUri" -ForegroundColor Green
