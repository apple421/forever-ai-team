#!/bin/bash
# AI 팀 - tmux 세션 시작 스크립트

SESSION="forever"
BASE_DIR="$HOME/forever-ai"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

source "$HOME/.bashrc" 2>/dev/null || true

if [ -z "$ANTHROPIC_API_KEY" ]; then
  echo -e "${RED}ANTHROPIC_API_KEY가 설정되지 않았습니다.${NC}"
  echo "install.sh를 먼저 실행하거나 ~/.bashrc에 API 키를 추가하세요."
  exit 1
fi

if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo -e "${YELLOW}기존 AI 팀 세션을 종료합니다...${NC}"
  tmux kill-session -t "$SESSION"
fi

echo -e "${CYAN}${BOLD}AI 팀을 시작합니다...${NC}"

# 세션 생성
tmux new-session -d -s "$SESSION" -x 220 -y 50

# pane 분할 (6개: 팀장 + 팀원 5)
tmux split-window -t "$SESSION:0.0" -h   # 좌/우 분할
tmux split-window -t "$SESSION:0.0" -v   # 좌 상/하
tmux split-window -t "$SESSION:0.1" -v   # 우 상/하
tmux split-window -t "$SESSION:0.2" -v   # 좌 하단 분할
tmux split-window -t "$SESSION:0.3" -v   # 우 하단 분할

tmux select-layout -t "$SESSION" tiled

# 각 pane에 Claude 실행
declare -A AGENTS=([0]="junhyeok" [1]="minjun" [2]="jihun" [3]="sua" [4]="seoyeon" [5]="taeyang")
declare -A LABELS=([0]="준혁 👑 팀장" [1]="민준 🏗 아키텍트" [2]="지훈 🔍 리서쳐" [3]="수아 🎨 UI/UX" [4]="서연 💻 개발자" [5]="태양 ✅ QA")

for i in "${!AGENTS[@]}"; do
  agent="${AGENTS[$i]}"
  label="${LABELS[$i]}"
  agent_dir="$BASE_DIR/$agent"

  tmux send-keys -t "$SESSION:0.$i" \
    "cd '$agent_dir' && echo '=== ${label} ===' && claude --dangerously-skip-permissions" Enter
  sleep 0.3
done

tmux select-pane -t "$SESSION:0.0"

echo -e "${GREEN}${BOLD}"
echo "╔═══════════════════════════════════╗"
echo "║       AI 팀 준비 완료!            ║"
echo "╠═══════════════════════════════════╣"
echo "║  0: 준혁 (팀장)                  ║"
echo "║  1: 민준 (아키텍트)              ║"
echo "║  2: 지훈 (리서쳐)                ║"
echo "║  3: 수아 (UI/UX)                 ║"
echo "║  4: 서연 (개발자)                ║"
echo "║  5: 태양 (QA)                    ║"
echo "╚═══════════════════════════════════╝"
echo -e "${NC}"

tmux attach-session -t "$SESSION"
