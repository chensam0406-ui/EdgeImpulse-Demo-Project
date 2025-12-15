echo "正在執行上傳 training"
edge-impulse-uploader \
  data/training/*.jpg \
  --api-key "${EI_API_KEY}" \
  --category training

echo "正在執行上傳 testing"
edge-impulse-uploader \
  data/testing/*.jpg \
  --api-key "${EI_API_KEY}" \
  --category testing

