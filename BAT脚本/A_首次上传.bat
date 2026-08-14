@echo off
chcp 65001 >nul
title Obsidian A - First Upload to GitHub

echo ==============================================================================
echo       Obsidian 学习笔记: A 电脑首次初始化并推送到 GitHub
echo ==============================================================================
echo.

call "%~dp000_config.bat"

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 系统未找到 Git，请先安装 Git for Windows
    pause
    exit /b 1
)

if not exist "%VAULT_PATH%" (
    echo [错误] 找不到 Obsidian 笔记库目录：%VAULT_PATH%
    pause
    exit /b 1
)

echo [1/4] 检查 .gitignore 文件...
if exist "%VAULT_PATH%\.gitignore" goto :git_init
echo .obsidian/workspace.json> "%VAULT_PATH%\.gitignore"
echo .obsidian/workspace-mobile.json>> "%VAULT_PATH%\.gitignore"
echo .obsidian/cache/>> "%VAULT_PATH%\.gitignore"
echo .trash/>> "%VAULT_PATH%\.gitignore"
echo .DS_Store>> "%VAULT_PATH%\.gitignore"
echo Thumbs.db>> "%VAULT_PATH%\.gitignore"
echo desktop.ini>> "%VAULT_PATH%\.gitignore"
echo *.tmp>> "%VAULT_PATH%\.gitignore"
echo 已自动生成 .gitignore

:git_init
echo.
echo [2/4] 进入笔记库并初始化 Git...
cd /d "%VAULT_PATH%"

if not exist ".git" git init
git branch -M "%BRANCH%"

echo.
echo [3/4] 关联远程 GitHub 仓库...
git remote get-url origin >nul 2>nul
if %errorlevel% neq 0 (
    git remote add origin "%REPO_URL%"
) else (
    git remote set-url origin "%REPO_URL%"
)

echo.
echo [4/4] 暂存并提交本地笔记，准备推送到 GitHub...
git add -A
git diff --cached --quiet
if %errorlevel% neq 0 (
    git commit -m "feat: Initial Obsidian vault upload"
)

echo.
echo 正在推送到 GitHub (%BRANCH% 分支)...
echo (如果是首次连接 GitHub，可能会弹出浏览器登录授权窗口，请按提示完成授权)
echo.

git push -u origin "%BRANCH%"
if %errorlevel% neq 0 goto :fail

echo.
echo ==============================================================================
echo  【成功】首次上传完成！你的全部笔记已安全同步到 GitHub。
echo ==============================================================================
echo.
pause
exit /b 0

:fail
echo.
echo ==============================================================================
echo  【提示】如果弹出登录窗口，请在浏览器中完成 GitHub 授权后重试。
echo  如果网络连接 GitHub 较慢或超时，请检查代理工具或网络连接。
echo ==============================================================================
echo.
pause
exit /b 1
