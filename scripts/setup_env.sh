#!/bin/bash

# ===============================================
# 腳本名稱: setup_env.sh
# 描述: 自動安裝 Edge Impulse CLI、Node.js 及 Python 3 環境
# ===============================================

# 顏色定義 (讓輸出更好看)
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}🚀 開始安裝 Edge Impulse 開發環境 (含 Python 3) ${NC}"
echo -e "${BLUE}=======================================${NC}"

# 1. 更新系統套件清單
echo -e "${GREEN}>>> 1. 更新系統套件清單...${NC}"
sudo apt update

# 2. 安裝必要系統工具與 Python 3
# python3-pip 是為了讓新人可以安裝 python 相關套件 (如 edgeimpulse-sdk)
echo -e "${GREEN}>>> 2. 安裝系統基礎工具與 Python 3...${NC}"
sudo apt install -y curl build-essential python3 python3-pip python3-dev
if [ $? -eq 0 ]; then
    echo "✅ Python 3 安裝成功: $(python3 --version)"
else
    echo "❌ Python 3 安裝失敗"
    exit 1
fi

# 3. 安裝 Node.js v18 (LTS)
echo -e "${GREEN}>>> 3. 安裝 Node.js v18 (LTS)...${NC}"
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
else
    echo "✅ Node.js 已存在，版本: $(node -v)"
fi

# 4. 安裝 Edge Impulse CLI
echo -e "${GREEN}>>> 4. 安裝 Edge Impulse CLI...${NC}"
# --unsafe-perm 解決 WSL 權限檢查問題
sudo npm install -g edge-impulse-cli --unsafe-perm

# 5. 驗證所有套件安裝狀態
echo -e "${BLUE}---------------------------------------${NC}"
echo -e "${BLUE}🔍 環境檢查結果：${NC}"
echo -n "Python 版本: "; python3 --version
echo -n "Pip 版本:    "; pip3 --version
echo -n "Node 版本:   "; node -v
echo -n "NPM 版本:    "; npm -v
echo -n "EI CLI 版本: "; edge-impulse-daemon --version
echo -e "${BLUE}---------------------------------------${NC}"

echo -e "${GREEN}✅ 所有環境已架設完成！${NC}"
echo -e "新人現在可以執行您的 push.sh 進行開發同步了。"
# 在原本的腳本末尾加入：
echo -e "${GREEN}>>> 安裝 Edge Impulse Python SDK...${NC}"
pip3 install edge_impulse_linux opencv-python --break-system-packages || pip3 install edge_impulse_linux opencv-python
