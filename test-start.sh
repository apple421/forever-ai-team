#!/usr/bin/env bash
# 테스트용 start.sh - API 키 체크 없이 실행

SESSION="forever-test"
BASE_DIR="$HOME/forever-ai"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
YELLOW='\033[1;33m'
NC='\033[0m'

if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo -e "${YELLOW}기존 테스트 세션 종료...${NC}"
  tmux kill-session -t "$SESSION"
fi

echo -e "${CYAN}${BOLD}AI 팀 테스트 시작...${NC}"

# 세션 생성
tmux new-session -d -s "$SESSION" -x 220 -y 50

# 6-pane 분할
tmux split-window -t "$SESSION:0.0" -h
tmux split-window -t "$SESSION:0.0" -v
tmux split-window -t "$SESSION:0.1" -v
tmux split-window -t "$SESSION:0.2" -v
tmux split-window -t "$SESSION:0.3" -v
tmux select-layout -t "$SESSION" tiled

# 에이전트 목록 (인덱스 배열)
AGENTS=(junhyeok minjun jihun sua seoyeon taeyang)
LABELS=("준혁 👑 팀장" "민준 🏗 아키텍트" "지훈 🔍 리서쳐" "수아 🎨 UI/UX" "서연 💻 개발자" "태양 ✅ QA")

for i in 0 1 2 3 4 5; do
  agent="${AGENTS[$i]}"
  label="${LABELS[$i]}"
  tmux send-keys -t "$SESSION:0.$i" \
    "cd '$BASE_DIR/$agent' && echo '=== ${label} ===' && claude --dangerously-skip-permissions" Enter
  sleep 0.5
done

tmux select-pane -t "$SESSION:0.0"

echo -e "${GREEN}${BOLD}"
echo "╔═══════════════════════════════════╗"
echo "║       AI 팀 테스트 준비 완료!     ║"
echo "╠═══════════════════════════════════╣"
echo "║  아래 명령어로 세션 접속:         ║"
echo "║  tmux attach -t forever-test      ║"
echo "╚═══════════════════════════════════╝"
echo -e "${NC}"
