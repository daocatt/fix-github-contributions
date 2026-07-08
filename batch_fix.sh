#!/bin/bash

# ================= 配置区域 =================
# 1. 你的 GitHub 用户名
GITHUB_USER="your-github-username"

# 2. 旧邮箱和新邮箱
OLD_EMAIL="your-old-email"
NEW_EMAIL="your-new-email"

# 3. 需要批量修正的仓库名称列表（用空格或换行隔开）
REPOS=(
    "your-repository-name"
)
# ============================================

# 报错即停止执行，确保安全
set -e

echo "🚀 开始批量修正 GitHub 仓库邮箱历史..."
echo "----------------------------------------"

for REPO in "${REPOS[@]}"; do
    echo "📂 [1/4] 正在镜像克隆仓库: ${REPO}..."
    git clone --mirror "git@github.com:${GITHUB_USER}/${REPO}.git"
    
    # 镜像克隆生成的目录名会自带 .git 
    cd "${REPO}.git"
    
    echo "🛠️  [2/4] 正在重写 ${REPO} 的所有分支和标签历史..."
    git filter-repo --email-callback "return b'${NEW_EMAIL}' if email == b'${OLD_EMAIL}' else email" --force
    
    echo "🔗 [3/4] 重新绑定远程仓库地址..."
    git remote add origin "git@github.com:${GITHUB_USER}/${REPO}.git"
    
    echo "📤 [4/4] 正在镜像强推至 GitHub..."
    git push origin --force 'refs/heads/*'
    git push origin --force --tags
    
    # 返回上级目录，准备处理下一个
    cd ..
    
    # 清理本地的临时镜像目录，释放空间（如果想保留，可以注释掉下面这行）
    rm -rf "${REPO}.git"
    
    echo "✅ 仓库 ${REPO} 修正完成！"
    echo "----------------------------------------"
done

echo "🎉 所有仓库处理完毕！绿格子正在赶来的路上。"