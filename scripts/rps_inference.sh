from edge_impulse_linux.image import ImageImpulseRunner
import cv2
import os
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "modelfile.eim")

# 命令列參數圖片優先
if len(sys.argv) > 1:
    IMAGE_PATH = sys.argv[1]
else:
    IMAGE_PATH = os.path.join(BASE_DIR, "test_images", "test.jpg")

LOSE_TO = {
    "stone": "scissor",
    "scissor": "paper",
    "paper": "stone"
}

runner = None

try:
    img = cv2.imread(IMAGE_PATH)
    if img is None:
        print("❌ 圖片讀取失敗:", IMAGE_PATH)
        sys.exit(1)

    runner = ImageImpulseRunner(MODEL_PATH)
    runner.init()

    features, _ = runner.get_features_from_image(img)
    result = runner.classify(features)

    boxes = result["result"].get("bounding_boxes", [])
    if not boxes:
        print("⚠️ 沒有偵測到手勢")
        sys.exit(0)

    best = max(boxes, key=lambda b: b['value'])
    detected_label = best['label']
    confidence = best['value']

    print(f"✋ 我們出的：{detected_label} ({confidence:.2f})")
    computer_choice = LOSE_TO.get(detected_label, "unknown")
    print(f"🤖 電腦必輸出：{computer_choice}")

except Exception as e:
    print("Error:", e)

finally:
    if runner:
        runner.stop()
