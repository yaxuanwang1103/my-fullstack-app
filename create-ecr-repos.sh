#!/bin/bash

# AWS ECR 仓库创建脚本

echo "========================================="
echo "   创建 AWS ECR 仓库"
echo "========================================="
echo ""

# 设置变量
AWS_REGION="${AWS_REGION:-us-east-2}"
REPOS=("todoapp-frontend" "todoapp-backend-a" "todoapp-backend-b")

echo "📍 区域: $AWS_REGION"
echo "📦 仓库列表: ${REPOS[@]}"
echo ""

# 创建仓库
for repo in "${REPOS[@]}"; do
    echo "🔧 创建仓库: $repo"
    
    aws ecr create-repository \
        --repository-name "$repo" \
        --region "$AWS_REGION" \
        --image-scanning-configuration scanOnPush=true \
        --encryption-configuration encryptionType=AES256 \
        2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ $repo 创建成功"
    else
        echo "⚠️  $repo 可能已存在，跳过"
    fi
    
    # 设置生命周期策略（保留最近 10 个镜像）
    echo "📋 设置生命周期策略..."
    aws ecr put-lifecycle-policy \
        --repository-name "$repo" \
        --region "$AWS_REGION" \
        --lifecycle-policy-text '{
            "rules": [
                {
                    "rulePriority": 1,
                    "description": "保留最近 10 个镜像",
                    "selection": {
                        "tagStatus": "any",
                        "countType": "imageCountMoreThan",
                        "countNumber": 10
                    },
                    "action": {
                        "type": "expire"
                    }
                }
            ]
        }' >/dev/null 2>&1
    
    echo ""
done

echo "========================================="
echo "✅ ECR 仓库创建完成！"
echo "========================================="
echo ""
echo "📊 查看仓库列表："
aws ecr describe-repositories --region "$AWS_REGION" --query 'repositories[].repositoryName' --output table

echo ""
echo "🔗 ECR 控制台："
echo "https://$AWS_REGION.console.aws.amazon.com/ecr/repositories"
