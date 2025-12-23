echo "正在執行上傳 training"
edge-impulse-uploader \
  --api-key "${EI_API_KEY}" \
  --category training \
  data/training/*.jpg

echo "正在執行上傳 testing"
edge-impulse-uploader \
  --api-key "${EI_API_KEY}" \
  --category testing \
  data/testing/*.jpg
