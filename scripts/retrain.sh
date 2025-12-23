#!/bin/bash

# --- 自動修正檔案換行格式 (防止 Windows/Linux 衝突) ---
if [[ -f "$0" ]]; then
    sed -i 's/\r$//' "$0"
fi

# --- 變數設定 ---
# 優先使用 .bashrc 裡的變數，若無則使用預設值
PID=${PROJECT_ID}
KEY=${EI_API_KEY}

echo "------------------------------------------"
echo "🛠️  Edge Impulse 官方標準重訓觸發器"
echo "📦 專案 ID: $PID"
echo "------------------------------------------"


RESPONSE=$(curl -s -X POST "https://studio.edgeimpulse.com/v1/api/${PID}/jobs/retrain" \
     -H "x-api-key: ${KEY}" \
     -H "Content-Type: application/json")

# --- 結果分析 ---
if [[ $RESPONSE == *"\"success\":true"* ]]; then
    # 從回應中抓取 Job ID
    JOB_ID=$(echo $RESPONSE | grep -oP '(?<="id":)\d+' | head -n 1)
    echo "✅ 成功啟動雲端任務！"
    echo "🔢 Job ID: $JOB_ID"
else
    echo "❌ 觸發失敗"
    echo "🔍 原始回應: $RESPONSE"
    echo "💡 提示: 若看到 404，請檢查 PID 是否正確；若看到 401，請檢查 API Key。"
fi
