@echo off
chcp 65001 >nul
title Obsidian - 一键拉取最新并打开笔记

echo ==============================================================================
echo       Obsidian 学习笔记: 一键拉取 GitHub 最新进度并启动 Obsidian
echo ==============================================================================
echo.

call "%~dp000_config.bat"

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未找到 Git
    pause
    exit /b 1
)

if not exist "%VAULT_PATH%\.git" (
    echo [错误] 笔记库目录尚未初始化 Git：%VAULT_PATH%
    echo 请先双击运行 [D_首次下载并打开.bat]
    pause
    exit /b 1
)

echo 正在从 GitHub 远端拉取最新笔记...
git -C "%VAULT_PATH%" pull --rebase origin "%BRANCH%"
if %errorlevel% neq 0 (
    echo.
    echo [警告] Pull 失败！为避免覆盖本地未同步的内容，暂不自动打开 Obsidian。
    pause
    exit /b 1
)

echo.
echo [成功] 笔记库已是最新状态，正在启动 Obsidian...
start "" "obsidian://open?path=%VAULT_PATH%"
exit /b 0
