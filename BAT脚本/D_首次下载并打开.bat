@echo off
chcp 65001 >nul
title Obsidian D - 首次下载并打开笔记

echo ==============================================================================
echo       Obsidian 学习笔记: D 电脑首次从 GitHub 克隆仓库并打开
echo ==============================================================================
echo.

call "%~dp000_config.bat"

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 系统未找到 Git，请先安装 Git for Windows
    pause
    exit /b 1
)

echo [1/3] 准备本地存放目录：%VAULT_PATH%
if exist "%VAULT_PATH%\.git" goto :do_pull

if exist "%VAULT_PATH%" (
    dir /b "%VAULT_PATH%" 2>nul | findstr . >nul
    if %errorlevel% equ 0 (
        echo [错误] 目标目录已存在且非空，但不是 Git 仓库：%VAULT_PATH%
        pause
        exit /b 1
    )
)

for %%I in ("%VAULT_PATH%") do if not exist "%%~dpI" mkdir "%%~dpI"
echo [2/3] 正在从 GitHub 克隆笔记仓库...
git clone --branch "%BRANCH%" "%REPO_URL%" "%VAULT_PATH%"
if %errorlevel% neq 0 goto :fail
goto :open_obsidian

:do_pull
echo 检测到该目录已存在 Git 仓库，正在直接拉取最新版本...
git -C "%VAULT_PATH%" pull --rebase origin "%BRANCH%"
if %errorlevel% neq 0 goto :fail

:open_obsidian
echo.
echo [3/3] 正在唤起 Obsidian 打开笔记库...
start "" "obsidian://open?path=%VAULT_PATH%"

echo.
echo ==============================================================================
echo  【完成】已成功下载笔记并在 Obsidian 中打开！
echo ==============================================================================
echo.
timeout /t 5 >nul 2>nul || pause
exit /b 0

:fail
echo.
echo ==============================================================================
echo  【失败】克隆或拉取失败！请查看上方的 Git 错误提示。
echo ==============================================================================
echo.
pause
exit /b 1
