# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'   # No Color（恢復預設）


echo -e "${BLUE}---------------------------------------${NC}"
echo -e "${BLUE}🔍 環境檢查結果：${NC}"
echo -n "Python 版本: "; python3 --version
echo -n "Pip 版本:    "; pip3 --version
echo -n "Node 版本:   "; node -v
echo -n "NPM 版本:    "; npm -v
echo -n "EI CLI 版本: "; edge-impulse-daemon --version
echo -e "${BLUE}---------------------------------------${NC}"
