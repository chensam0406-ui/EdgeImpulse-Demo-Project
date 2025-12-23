#!/bin/bash

# 定義顏色，讓介面更漂亮
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 確保腳本執行時能讀取到 .bashrc 的環境變數
source ~/.bashrc 2>/dev/null

show_menu() {
    clear
    echo -e "${BLUE}=========================================="
    echo -e "      🚀 Edge Impulse 專案管理選單"
    echo -e "      目前目錄: $(pwd)"
    echo -e "==========================================${NC}"
    echo -e "${YELLOW}1)${NC} 啟動模型推理 (Inference)"
    echo -e "${YELLOW}2)${NC} 觸發雲端重新訓練 (Retrain)"
    echo -e "${YELLOW}3)${NC} 提交並推送到 GitHub (Push)"
    echo -e "${YELLOW}4)${NC} 重新載入環境變數 (Source .bashrc)"
    echo -e "${YELLOW}5)${NC} 登入/切換 Edge Impulse 帳號 (Login)"
    echo -e "${YELLOW}q)${NC} 退出 (Quit)"
    echo -e "${BLUE}------------------------------------------${NC}"
}

while true; do
    show_menu
    read -p "請輸入選項 [1-5 或 q]: " choice

    case $choice in
        1)
            echo -e "${GREEN}>> 執行推理腳本...${NC}"
            bash ./scripts/rps_inference.sh
            read -p "按 Enter 回到選單..."
            ;;
        2)
            echo -e "${GREEN}>> 執行重訓腳本...${NC}"
            bash ./scripts/retrain.sh
            read -p "按 Enter 回到選單..."
            ;;
        3)
            echo -e "${GREEN}>> 執行 Git 推送...${NC}"
            bash ./scripts/push.sh
            read -p "按 Enter 回到選單..."
            ;;
        4)
            echo -e "${GREEN}>> 重新載入 .bashrc...${NC}"
            source ~/.bashrc
            echo "已完成載入。"
            sleep 1
            ;;
        5)
            echo -e "${GREEN}>> 啟動 Edge Impulse 登入程序...${NC}"
            edge-impulse-login
            read -p "按 Enter 回到選單..."
            ;;
        q|Q)
            echo "掰掰！"
            exit 0
            ;;
        *)
            echo -e "${RED}錯誤選項，請重新輸入！${NC}"
            sleep 1
            ;;
    esac
done
