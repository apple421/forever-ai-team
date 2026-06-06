#!/bin/bash
# =============================================================
#  Google Drive / Gmail OAuth 별도 설정 스크립트
#  install.sh에서 건너뛴 경우 나중에 실행
# =============================================================

CONFIG_DIR="$HOME/.config/nephro-ai"
mkdir -p "$CONFIG_DIR"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${CYAN}${BOLD}Google Drive / Gmail 인증 설정${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}사전 준비 (PREREQUISITES.md > Google OAuth 섹션 참고):${NC}"
echo "  1. Google Cloud Console에서 프로젝트 생성"
echo "  2. Drive API + Gmail API 활성화"
echo "  3. OAuth 동의 화면 설정"
echo "  4. OAuth 2.0 클라이언트 ID 생성 (데스크톱 앱)"
echo "  5. credentials.json 다운로드"
echo ""

read -p "credentials.json 파일 경로를 입력하세요: " CRED_PATH
CRED_PATH="${CRED_PATH//\'/}"
CRED_PATH="${CRED_PATH%/}"

if [ -z "$CRED_PATH" ] || [ ! -f "$CRED_PATH" ]; then
  echo -e "${RED}파일을 찾을 수 없습니다: $CRED_PATH${NC}"
  exit 1
fi

cp "$CRED_PATH" "$CONFIG_DIR/gcp-credentials.json"
echo -e "${GREEN}✓ credentials.json 저장 완료${NC}"

echo ""
echo -e "${YELLOW}Google Drive 인증 테스트...${NC}"
echo "(브라우저 창이 열리면 Google 계정으로 로그인하세요)"
echo ""

# Google Drive 첫 인증 실행
GDRIVE_CREDENTIALS_PATH="$CONFIG_DIR/gcp-credentials.json" \
GDRIVE_TOKEN_PATH="$CONFIG_DIR/gdrive-token.json" \
npx -y @modelcontextprotocol/server-gdrive 2>&1 | head -20

echo ""
echo -e "${YELLOW}Gmail 인증 테스트...${NC}"

GMAIL_CREDENTIALS_PATH="$CONFIG_DIR/gcp-credentials.json" \
GMAIL_TOKEN_PATH="$CONFIG_DIR/gmail-token.json" \
npx -y @gongrzhe/server-gmail-autoauth-mcp 2>&1 | head -20

echo ""
echo -e "${GREEN}${BOLD}Google 인증 설정 완료!${NC}"
echo -e "토큰 저장 위치: ${CYAN}$CONFIG_DIR/${NC}"
