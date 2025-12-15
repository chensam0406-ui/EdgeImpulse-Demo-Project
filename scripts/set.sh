#!/bin/bash
# 遇到任何錯誤立即中止腳本 

echo "--- Starting Environment Setup ---"

# --- 1. 定義路徑並建立檔案 ---
export PROJECT_ROOT=$(pwd)
echo "PROJECT_ROOT calculated: $PROJECT_ROOT"

# 獲取當前日期 (MMDD 格式)
TODAY=$(date +%m%d)

# 定義 log 檔案名稱 (例如: 1214.log)
LOG_FILENAME="${TODAY}.log"

# 正確定義 LOG_FILE_PATH
export LOG_DIR="${PROJECT_ROOT}/logs"
export LOG_FILE_PATH="${LOG_DIR}/${LOG_FILENAME}"
touch ${LOG_FILE_PATH}

echo "input_EI_API_KEY:"
read -r input_EI_API_KEY
export EI_API_KEY="$input_EI_API_KEY"

echo "inputinput_PROJECT:"
read -r input_PROJECT_ID
export PROJECT_ID="$input_PROJECT_ID"


