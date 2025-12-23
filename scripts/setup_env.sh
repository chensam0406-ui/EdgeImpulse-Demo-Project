#!/bin/bash

# ===============================================
# 腳本名稱: setup_env.sh
# 描述: 自動安裝 Edge Impulse CLI、Node.js 22、Python 3 及音訊影像相關 SDK
# ===============================================

# 顏色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}🚀 開始安裝 Edge Impulse 開發環境 (2025 更新版) ${NC}"
echo -e "${BLUE}=======================================${NC}"

# 1. 更新系統套件清單
echo -e "${GREEN}>>> 1. 更新系統套件清單...${NC}"
sudo apt update

# 2. 安裝必要系統工具、Python 3 以及「音訊/影像底層套件」
# 加入 libasound2-dev 等套件是為了確保 pyaudio 能夠順利編譯與運行
echo -e "${GREEN}>>> 2. 安裝系統基礎工具、Python 3 與音訊底層開發庫...${NC}"
sudo apt install -y curl build-essential python3 python3-pip python3-dev \
libasound2-dev libportaudio2 libportaudiocpp0 portaudio19-dev libopencv-dev

if [ $? -eq 0 ]; then
    echo "✅ 系統基礎工具安裝成功: $(python3 --version)"
else
    echo "❌ 系統工具安裝失敗"
    exit 1
fi

# 3. 安裝 Node.js v22 (LTS) - 避免 v18 的棄用警告
echo -e "${GREEN}>>> 3. 安裝 Node.js v22 (LTS)...${NC}"
if ! command -v node &> /dev/null; then
    # 這裡改成 setup_22.x 確保版本最新且安全
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt install -y nodejs
else
    echo "✅ Node.js 已存在，版本: $(node -v)"
fi

# 4. 安裝 Edge Impulse CLI (Node.js 套件)
echo -e "${GREEN}>>> 4. 安裝 Edge Impulse CLI...${NC}"
sudo npm install -g edge-impulse-cli --unsafe-perm
sudo npm install -g edge-impulse-linux
# 5. 安裝 Edge Impulse Python SDK 與相關依賴 (影像+音訊)
echo -e "${GREEN}>>> 5. 安裝 Edge Impulse Python SDK, OpenCV 與 PyAudio...${NC}"
# 這裡一次補齊 edge_impulse_linux, opencv-python 與你遇到的缺失組件 pyaudio
pip3 install edge_impulse_linux opencv-python pyaudio --break-system-packages || \
pip3 install edge_impulse_linux opencv-python pyaudio

# 6. 驗證所有套件安裝狀態
echo -e "${BLUE}---------------------------------------${NC}"
echo -e "${BLUE}🔍 環境檢查結果：${NC}"
echo -n "Python 版本: "; python3 --version
echo -n "Pip 版本:    "; pip3 --version
echo -n "Node 版本:   "; node -v
echo -n "NPM 版本:    "; npm -v
echo -n "EI CLI 版本: "; edge-impulse-daemon --version
echo -e "${BLUE}---------------------------------------${NC}"

echo -e "${GREEN}✅ 所有環境已架設完成！${NC}"
echo -e "新人現在可以執行您的 push.sh 進行開發同步，"
echo -e "或執行 python3 scripts/rps_inference.sh 進行推論了。"
