#!/bin/bash
# =============================================================
#  AI 팀 - WSL2 자동 설치 스크립트
#  실행: bash install.sh
# =============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

INSTALL_DIR="$HOME/forever-ai"
CONFIG_DIR="$HOME/.config/forever-ai"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS=("junhyeok" "minjun" "jihun" "sua" "seoyeon" "taeyang" "haeun")

print_banner() {
  echo ""
  echo -e "${BLUE}${BOLD}╔══════════════════════════════════════╗${NC}"
  echo -e "${BLUE}${BOLD}║     AI 팀 설치 프로그램     ║${NC}"
  echo -e "${BLUE}${BOLD}║  Rehab AI Team Installer v1.0   ║${NC}"
  echo -e "${BLUE}${BOLD}╚══════════════════════════════════════╝${NC}"
  echo ""
}

step() {
  echo -e "\n${CYAN}${BOLD}[$1/$TOTAL_STEPS] $2${NC}"
}

ok() { echo -e "  ${GREEN}✓ $1${NC}"; }
warn() { echo -e "  ${YELLOW}⚠ $1${NC}"; }
fail() { echo -e "  ${RED}✗ $1${NC}"; exit 1; }

TOTAL_STEPS=8

print_banner

# ── Step 1: 시스템 패키지 ──────────────────────────────────
step 1 "시스템 패키지 설치 (git, curl, tmux)"
sudo apt-get update -q 2>&1 | tail -1
sudo apt-get install -y -q git curl tmux jq 2>&1 | tail -1
ok "시스템 패키지 완료"

# ── Step 2: Node.js ────────────────────────────────────────
step 2 "Node.js 설치 확인"
if ! command -v node &>/dev/null || [[ $(node -v | tr -d 'v' | cut -d. -f1) -lt 18 ]]; then
  echo "  Node.js 20 설치 중..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - 2>/dev/null
  sudo apt-get install -y nodejs 2>&1 | tail -1
  ok "Node.js $(node -v) 설치 완료"
else
  ok "Node.js $(node -v) 이미 설치됨"
fi

# ── Step 3: Claude CLI ─────────────────────────────────────
step 3 "Claude CLI 설치"
if ! command -v claude &>/dev/null; then
  npm install -g @anthropic-ai/claude-code 2>&1 | tail -3
  ok "Claude CLI 설치 완료"
else
  ok "Claude CLI 이미 설치됨"
fi

# ── Step 4: MCP 서버 사전 다운로드 ────────────────────────
step 4 "MCP 서버 설치 (Git, Google Drive, Gmail)"
npm install -g \
  @modelcontextprotocol/server-git \
  @modelcontextprotocol/server-gdrive \
  @gongrzhe/server-gmail-autoauth-mcp \
  2>&1 | tail -3
ok "MCP 서버 준비 완료"

# ── Step 5: 디렉터리 구조 생성 ────────────────────────────
step 5 "워크스페이스 디렉터리 생성"
mkdir -p "$CONFIG_DIR"
mkdir -p "$INSTALL_DIR/workspace"
for folder in papers lectures analysis reviews writing ideas; do
  mkdir -p "$INSTALL_DIR/workspace/$folder"
done
ok "디렉터리 생성 완료: $INSTALL_DIR"

# ── Step 6: 에이전트 설정 복사 ────────────────────────────
step 6 "에이전트 설정 파일 배포"
for agent in "${AGENTS[@]}"; do
  target="$INSTALL_DIR/$agent"
  mkdir -p "$target"
  cp "$SCRIPT_DIR/agents/$agent/CLAUDE.md" "$target/CLAUDE.md"

  # settings.json 경로 치환
  sed \
    -e "s|WORKSPACE_PATH|$INSTALL_DIR/workspace|g" \
    -e "s|CONFIG_DIR|$CONFIG_DIR|g" \
    "$SCRIPT_DIR/agents/$agent/settings.json" > "$target/settings.json"

  ok "$agent 설정 완료"
done

# ── Step 7: Claude API 키 설정 ────────────────────────────
step 7 "Claude API 키 설정"
if grep -q "ANTHROPIC_API_KEY" "$HOME/.bashrc" 2>/dev/null && \
   [ -n "$ANTHROPIC_API_KEY" ]; then
  ok "API 키 이미 설정됨"
else
  echo ""
  echo -e "  ${YELLOW}Claude API 키가 필요합니다.${NC}"
  echo -e "  발급 주소: ${CYAN}https://console.anthropic.com/settings/keys${NC}"
  echo ""
  read -p "  ANTHROPIC_API_KEY 입력 (없으면 Enter로 건너뜀): " API_KEY
  if [ -n "$API_KEY" ]; then
    # 기존 항목 제거 후 추가
    sed -i '/ANTHROPIC_API_KEY/d' "$HOME/.bashrc" 2>/dev/null || true
    echo "export ANTHROPIC_API_KEY=\"$API_KEY\"" >> "$HOME/.bashrc"
    export ANTHROPIC_API_KEY="$API_KEY"
    ok "API 키 저장 완료 (~/.bashrc)"
  else
    warn "API 키 건너뜀 - 나중에 직접 ~/.bashrc에 추가하세요"
  fi
fi

# ── Step 8: Google OAuth 설정 ────────────────────────────
step 8 "Google Drive / Gmail 인증 설정"
if [ -f "$CONFIG_DIR/gcp-credentials.json" ]; then
  ok "Google 인증 파일 이미 존재"
else
  echo ""
  echo -e "  ${YELLOW}Google Drive, Gmail 사용을 위한 OAuth 설정입니다.${NC}"
  echo -e "  설정 방법은 ${CYAN}PREREQUISITES.md${NC} 의 'Google OAuth' 섹션을 참고하세요."
  echo ""
  read -p "  credentials.json 파일 경로 입력 (없으면 Enter 건너뜀): " CRED_PATH
  CRED_PATH="${CRED_PATH//\'/}"  # 따옴표 제거
  CRED_PATH="${CRED_PATH%/}"     # 후행 슬래시 제거

  if [ -n "$CRED_PATH" ] && [ -f "$CRED_PATH" ]; then
    cp "$CRED_PATH" "$CONFIG_DIR/gcp-credentials.json"
    ok "Google 인증 파일 저장 완료"
    echo ""
    echo -e "  ${CYAN}Google Drive 첫 실행 시 브라우저 인증이 필요합니다.${NC}"
    echo -e "  AI 팀 실행 후 각 pane에서 gdrive 첫 사용 시 URL이 출력됩니다."
  else
    warn "Google 인증 건너뜀 - 나중에 setup-google.sh를 실행하세요"
  fi
fi

# ── 워크스페이스 Git 초기화 ───────────────────────────────
cd "$INSTALL_DIR/workspace"
git init -q 2>/dev/null || true
git config user.email "forever-ai@research.local" 2>/dev/null || true
git config user.name "Nephro AI Team" 2>/dev/null || true

# ── 런처 스크립트 복사 ────────────────────────────────────
cp "$SCRIPT_DIR/start.sh" "$INSTALL_DIR/start.sh"
chmod +x "$INSTALL_DIR/start.sh"

# ── ~/.bashrc source ──────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║         설치 완료!                   ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "  AI 팀 시작 방법:"
echo -e "  ${CYAN}${BOLD}1. Windows 바탕화면의 [AI팀 시작.bat] 더블클릭${NC}"
echo -e "     또는"
echo -e "  ${CYAN}${BOLD}2. WSL 터미널에서: bash ~/forever-ai/start.sh${NC}"
echo ""
echo -e "  ${YELLOW}* API 키 적용을 위해 WSL 창을 한 번 닫고 다시 여세요.${NC}"
echo ""
