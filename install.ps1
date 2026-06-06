# =============================================================
#  AI 팀 - Windows PowerShell 설치 진입점
#  WSL2 상태 확인 후 install.sh 실행
# =============================================================

$Host.UI.RawUI.WindowTitle = "AI 팀 설치"
$ErrorActionPreference = "Stop"

function Write-Color($text, $color = "White") {
    Write-Host $text -ForegroundColor $color
}

function Test-WSL2 {
    try {
        $result = wsl --status 2>&1
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

function Test-WSLDistro {
    $distros = wsl --list --quiet 2>&1
    return ($distros -match "Ubuntu")
}

Write-Color "`n[1/4] WSL2 설치 상태 확인..." "Cyan"

# WSL2 확인
if (-not (Test-WSL2)) {
    Write-Color "`n  WSL2가 설치되어 있지 않습니다." "Red"
    Write-Color "  다음 단계를 따라 설치하세요:" "Yellow"
    Write-Color ""
    Write-Color "  1. PowerShell을 관리자 권한으로 실행" "White"
    Write-Color "  2. 아래 명령어 실행:" "White"
    Write-Color "     wsl --install" "Cyan"
    Write-Color "  3. 컴퓨터 재시작 후 Ubuntu 계정 생성" "White"
    Write-Color "  4. 이 설치 파일을 다시 실행" "White"
    Write-Color ""
    Write-Color "  자세한 방법: PREREQUISITES.md 참고" "Yellow"
    Read-Host "`n  Enter를 눌러 종료"
    exit 1
}

Write-Color "  WSL2 확인 완료" "Green"

# Ubuntu 배포판 확인
Write-Color "`n[2/4] Ubuntu 배포판 확인..." "Cyan"
if (-not (Test-WSLDistro)) {
    Write-Color "  Ubuntu가 없습니다. 설치합니다..." "Yellow"
    wsl --install -d Ubuntu
    Write-Color "  Ubuntu 설치 후 이 파일을 다시 실행하세요." "Yellow"
    Read-Host "  Enter를 눌러 종료"
    exit 1
}
Write-Color "  Ubuntu 확인 완료" "Green"

# 프로젝트 파일을 WSL2 홈으로 복사
Write-Color "`n[3/4] 프로젝트 파일을 WSL2로 복사..." "Cyan"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$wslScriptDir = wsl wslpath -u "$scriptDir" 2>&1

wsl bash -c "cp -r '$wslScriptDir' ~/forever-ai-deploy-src 2>/dev/null; echo ok"
Write-Color "  파일 복사 완료" "Green"

# install.sh 실행
Write-Color "`n[4/4] 자동 설치 시작..." "Cyan"
Write-Color "  (이 단계는 5-10분 소요될 수 있습니다)" "Yellow"
Write-Color ""

wsl bash -c "cd ~/forever-ai-deploy-src && bash install.sh"

if ($LASTEXITCODE -eq 0) {
    Write-Color "`n설치가 완료되었습니다!" "Green"
    Write-Color "바탕화면의 [AI팀 시작.bat]을 더블클릭하여 시작하세요." "Cyan"

    # 바탕화면에 시작 바로가기 생성
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutContent = @"
@echo off
chcp 65001 >nul
title AI 팀
wsl bash -c "source ~/.bashrc && bash ~/forever-ai/start.sh"
if %ERRORLEVEL% NEQ 0 pause
"@
    $shortcutContent | Out-File -FilePath "$desktopPath\AI팀 시작.bat" -Encoding UTF8
    Write-Color "`n  바탕화면에 [AI팀 시작.bat] 바로가기를 만들었습니다." "Green"
} else {
    Write-Color "`n설치 중 오류가 발생했습니다." "Red"
    Write-Color "PREREQUISITES.md를 확인하거나 설치 로그를 검토하세요." "Yellow"
}

Read-Host "`n  Enter를 눌러 종료"
