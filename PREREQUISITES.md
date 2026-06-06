# 사전 설치 필수 항목

신장내과 AI 팀을 사용하기 위해 아래 항목들을 먼저 설치해야 합니다.

---

## 1. WSL2 (Windows Subsystem for Linux 2)

**설치 방법:**

1. **PowerShell을 관리자 권한으로 실행**
   - 시작 버튼 우클릭 → "Windows PowerShell (관리자)" 클릭

2. **아래 명령어 실행:**
   ```powershell
   wsl --install
   ```

3. **컴퓨터 재시작**

4. **재시작 후 Ubuntu 창이 자동으로 열리면:**
   - 사용자 이름 입력 (영문, 소문자, 예: `professor`)
   - 비밀번호 입력 (화면에 표시되지 않음)

5. **설치 확인:**
   ```powershell
   wsl --list --verbose
   ```
   Ubuntu가 보이면 성공입니다.

**참고:** Windows 10 버전 2004 (빌드 19041) 이상 또는 Windows 11 필요

---

## 2. Windows Terminal (권장)

더 나은 화면 표시를 위해 Windows Terminal 설치를 권장합니다.

- **Microsoft Store에서 설치:** "Windows Terminal" 검색
- 또는 https://aka.ms/terminal 에서 다운로드

---

## 3. Claude API 키

Claude AI를 사용하기 위한 API 키입니다.

**발급 방법:**

1. https://console.anthropic.com 접속
2. 계정 생성 또는 로그인
3. "Settings" → "API Keys" → "Create Key"
4. 생성된 키를 안전한 곳에 보관

**비용:** Claude Max 플랜 사용 시 별도 과금 없음

---

## 4. Google OAuth 설정 (Google Drive / Gmail 사용 시)

Google Drive와 Gmail 연동을 위한 설정입니다.

### 4-1. Google Cloud Console 프로젝트 생성

1. https://console.cloud.google.com 접속
2. 상단 프로젝트 선택 → "새 프로젝트"
3. 프로젝트 이름: `nephro-ai-team` (또는 원하는 이름)
4. "만들기" 클릭

### 4-2. API 활성화

1. 좌측 메뉴 → "API 및 서비스" → "라이브러리"
2. **"Google Drive API"** 검색 → 활성화
3. **"Gmail API"** 검색 → 활성화

### 4-3. OAuth 동의 화면 설정

1. "API 및 서비스" → "OAuth 동의 화면"
2. 사용자 유형: **"외부"** 선택 → 만들기
3. 앱 이름: `Nephro AI Team`
4. 사용자 지원 이메일: 본인 이메일 입력
5. 저장 후 계속 (나머지는 기본값)
6. **"테스트 사용자"** 추가: 본인 Google 계정 이메일 추가

### 4-4. OAuth 클라이언트 ID 생성

1. "API 및 서비스" → "사용자 인증 정보"
2. "+ 사용자 인증 정보 만들기" → "OAuth 클라이언트 ID"
3. 애플리케이션 유형: **"데스크톱 앱"** 선택
4. 이름: `Nephro AI Client`
5. "만들기" 클릭
6. **"JSON 다운로드"** 클릭 → `credentials.json` 파일 저장

### 4-5. 설치 시 credentials.json 경로 입력

- 설치 스크립트 실행 시 credentials.json 파일 경로를 입력하세요
- 예: `/mnt/c/Users/사용자명/Downloads/credentials.json`

---

## 설치 순서 요약

```
1. WSL2 설치 (컴퓨터 재시작 필요)
2. Windows Terminal 설치 (선택)
3. Claude API 키 발급
4. Google OAuth credentials.json 다운로드
5. install.bat 더블클릭으로 자동 설치
```

---

## 문제 해결

**WSL2 설치 후 Ubuntu가 열리지 않는 경우:**
- 시작 메뉴에서 "Ubuntu" 검색 후 실행

**API 키를 나중에 입력하고 싶은 경우:**
- WSL 터미널에서 아래 명령 실행:
  ```bash
  echo 'export ANTHROPIC_API_KEY="여기에_키_입력"' >> ~/.bashrc
  source ~/.bashrc
  ```

**Google 인증을 나중에 설정하고 싶은 경우:**
- WSL 터미널에서 실행:
  ```bash
  bash ~/nephro-ai/setup-google.sh
  ```
