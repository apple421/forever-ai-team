@echo off
chcp 65001 >nul
title 신장내과 AI 팀 설치

echo.
echo  ╔══════════════════════════════════════╗
echo  ║     신장내과 AI 팀 설치 프로그램     ║
echo  ╚══════════════════════════════════════╝
echo.

:: PowerShell 실행 정책 확인 및 install.ps1 실행
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"

if %ERRORLEVEL% NEQ 0 (
  echo.
  echo  오류가 발생했습니다. install.ps1 을 직접 실행해 보세요.
  pause
  exit /b 1
)

pause
