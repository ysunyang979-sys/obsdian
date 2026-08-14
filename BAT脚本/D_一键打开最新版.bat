@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Obsidian - 一键拉取最新并打开笔记

echo ==============================================================================
echo       【Obsidian 学习笔记】一键拉取 GitHub 最新进度并启动 Obsidian
echo ==============================================================================
echo.

:: 1. 读取配置文件
call "%~dp000_配置.bat"

:: 2. 检查 Git
where git >nul 2>nul
if errorlevel 1 (
  echo [错误] 未找到 Git。
  pause
  exit /b 1
)

:: 3. 检查 Vault 存在
if not exist "%VAULT_PATH%\.git" (
  echo [错误] 笔记库目录尚未初始化 Git：%VAULT_PATH%
  echo 请先双击运行 [D_首次下载并打开.bat] 下载笔记库。
  echo.
  pause
  exit /b 1
)

echo 正在从 GitHub 远端拉取最新笔记...
git -C "%VAULT_PATH%" pull --rebase origin "%BRANCH%"
if errorlevel 1 (
  echo.
  echo [警告] Pull 失败！为避免覆盖本地未同步的内容，暂不自动打开 Obsidian。
  echo 请排查网络或先备份冲突文件。
  echo.
  pause
  exit /b 1
)

echo.
echo [成功] 笔记库已是最新状态，正在启动 Obsidian...
start "" "obsidian://open?path=%VAULT_PATH%"
exit /b 0
