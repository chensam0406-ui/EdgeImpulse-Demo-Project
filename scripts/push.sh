#!/bin/bash

# ===============================================
# 腳本名稱: push.sh (Git 自動化推送腳本)
# 描述: 檢查本地是否有變更，如果有，則自動執行
#      git add .、git commit、git pull 和 git push。
# ===============================================

# --- 1. 變數定義 ---
# 設定預設的分支名稱 (通常是 main 或 master)
BRANCH_NAME="main"

# --- 2. 函數定義 ---
# 函數: 檢查上次指令是否成功
check_status() {
    if [ $? -ne 0 ]; then
        echo "❌ 錯誤: 上個 Git 操作失敗。請手動檢查並修復。"
        exit 1
    fi
}

# --- 3. 獲取提交訊息 ---
if [ -z "$1" ]; then
    # 如果使用者沒有提供訊息，則使用預設訊息
    COMMIT_MESSAGE="Auto update $(date '+%Y-%m-%d %H:%M:%S')"
else
    # 否則使用使用者輸入的第一個參數作為訊息
    COMMIT_MESSAGE="$1"
fi

echo "--- 🚀 正在準備提交 ---"
echo "使用提交訊息: $COMMIT_MESSAGE"
echo "----------------------"

# --- 4. 核心 Git 流程 ---

# 4.1. 檢查是否有變更
git status --porcelain
if [ $? -ne 0 ]; then
    echo "❌ 錯誤: 無法執行 git status。"
    exit 1
fi

if [ -z "$(git status --porcelain)" ]; then
    echo "✅ 狀態: 工作區乾淨，沒有變更需要提交。"
else
    # 4.2. 新增 (Add) 所有變更到暫存區
    echo "--- 📦 新增所有變更 ---"
    git add .
    check_status

    # 4.3. 提交 (Commit) 變更
    echo "--- ✍️ 提交本地版本 ---"
    git commit -m "$COMMIT_MESSAGE"
    check_status
fi

# 4.4. 拉取 (Pull) 遠端最新變更並合併
echo "--- ⬇️ 拉取遠端最新變更 (Merge) ---"
git pull origin "$BRANCH_NAME"
check_status

# 4.5. 推送 (Push) 本地提交到 GitHub
echo "--- ⬆️ 推送到 GitHub ---"
git push origin "$BRANCH_NAME"
check_status

echo "====================================="
echo "✅ 成功: 專案已同步到 GitHub (分支: $BRANCH_NAME)"
echo "====================================="
