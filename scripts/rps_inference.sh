from edge_impulse_linux.image import ImageImpulseRunner
import cv2
import os
import sys

# --------------------------------------
# 資料夾路徑設定
# --------------------------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))      # scripts/
PROJECT_DIR = os.path.dirname(BASE_DIR)                    # 專案根目錄
MODEL_PATH = os.path.join(PROJECT_DIR, "models", "modelfile.eim")  # 模型路徑
TESTING_DIR = os.path.join(PROJECT_DIR, "data", "testing")         # testing 資料夾

# --------------------------------------
# RPS 對應
# --------------------------------------
LOSE_TO = {
    "stone": "scissor",
    "scissor": "paper",
    "paper": "stone"
}

runner = None

try:
    # 檢查 testing 資料夾
    if not os.path.isdir(TESTING_DIR):
        print("❌ 找不到 testing 資料夾:", TESTING_DIR)
        sys.exit(1)

    # 取得所有圖片
    image_files = sorted([
        f for f in os.listdir(TESTING_DIR)
        if f.lower().endswith((".jpg", ".jpeg", ".png"))
    ])

    if not image_files:
        print("⚠️ testing 資料夾內沒有圖片")
        sys.exit(0)

    # 初始化 Edge Impulse Runner
    runner = ImageImpulseRunner(MODEL_PATH)
    runner.init()

    # --------------------------------------
    # 逐張圖片做推論
    # --------------------------------------
    for img_name in image_files:
        image_path = os.path.join(TESTING_DIR, img_name)
        img = cv2.imread(image_path)

        if img is None:
            print(f"❌ 讀取失敗: {img_name}")
            continue

        features, _ = runner.get_features_from_image(img)
        result = runner.classify(features)

        boxes = result["result"].get("bounding_boxes", [])
        if not boxes:
            print(f"⚠️ {img_name}：沒有偵測到手勢")
            continue

        # 選出置信度最高的
        best = max(boxes, key=lambda b: b['value'])
        detected_label = best['label']
        confidence = best['value']

        print(f"📷 {img_name}")
        print(f"✋ 我們出的：{detected_label} ({confidence:.2f})")

        computer_choice = LOSE_TO.get(detected_label, "unknown")
        print(f"🤖 電腦必輸出：{computer_choice}")
        print("-" * 40)

except Exception as e:
    print("❌ Error:", e)

finally:
    if runner:
        runner.stop()
