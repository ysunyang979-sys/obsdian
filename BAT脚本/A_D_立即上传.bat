@echo off
chcp 65001 >nul
title Obsidian - 一键双向同步

echo ==============================================================================
echo       Obsidian 学习笔记: 一键双向同步 (提交 + 拉取 + 推送)
echo ==============================================================================
echo.

call "%~dp000_config.bat"

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 系统未找到 Git
    pause
    exit /b 1
)

if not exist "%VAULT_PATH%\.git" (
    echo [错误] 笔记库尚未初始化 Git 仓库：%VAULT_PATH%
    echo 请先运行 [A_首次上传.bat]
    pause
    exit /b 1
)

cd /d "%VAULT_PATH%"

echo [1/3] 正在保存本地所有笔记修改...
git add -A
git diff --cached --quiet
if %errorlevel% neq 0 (
    git commit -m "sync: auto-sync from %COMPUTERNAME% at %DATE% %TIME%"
    echo 本地修改已成功保存并提交
) else (
    echo 本地笔记无新增修改
)

echo.
echo [2/3] 正在从 GitHub 拉取远端最新笔记 (Pull --rebase)...
git pull --rebase origin "%BRANCH%"
if %errorlevel% neq 0 goto :fail

echo.
echo [3/3] 正在将最新笔记推送到 GitHub (Push)...
git push origin "%BRANCH%"
if %errorlevel% neq 0 goto :fail

echo.
echo ==============================================================================
echo  【完成】同步成功！当前电脑与 GitHub 远端笔记已完全保持最新同步！
echo ==============================================================================
echo.
timeout /t 3 >nul 2>nul || pause
exit /b 0

:fail
echo.
echo ==============================================================================
echo  【失败】同步未完成，请检查上方的 Git 提示信息。
echo ==============================================================================
echo.
pause
exit /b 1
