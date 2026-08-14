@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Obsidian - 快速双向同步 (提交 + 拉取 + 推送)

echo ==============================================================================
echo       【Obsidian 学习笔记】一键双向同步 (Commit + Pull --rebase + Push)
echo ==============================================================================
echo.

:: 1. 读取配置文件
call "%~dp000_配置.bat"

:: 2. 检查 Git 是否安装
where git >nul 2>nul
if errorlevel 1 (
  echo [错误] 系统未找到 Git。
  pause
  exit /b 1
)

:: 3. 检查 Vault 及 .git 状态
if not exist "%VAULT_PATH%\.git" (
  echo [错误] 该笔记库尚未初始化 Git 仓库：%VAULT_PATH%
  echo 如果是首次使用，请先运行 [A_首次上传.bat] 或 [D_首次下载并打开.bat]。
  echo.
  pause
  exit /b 1
)

pushd "%VAULT_PATH%"

echo [1/3] 正在保存本地所有笔记修改并生成记录...
git add -A
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "sync: auto-sync from %COMPUTERNAME% at %DATE% %TIME%"
  if errorlevel 1 goto :fail
  echo       本地修改已成功提交。
) else (
  echo       本地笔记无新增修改。
)

echo.
echo [2/3] 正在从 GitHub 拉取远端最新笔记 (Pull --rebase)...
git pull --rebase origin "%BRANCH%"
if errorlevel 1 (
  echo.
  echo [警告] 拉取远端更新时发生冲突或网络失败！
  echo 如果是代码/文本冲突，请打开笔记解决冲突标记（<<<<<<<）后重新运行本脚本。
  goto :fail
)
echo       远端笔记拉取并合并成功。

echo.
echo [3/3] 正在将最新笔记推送到 GitHub (Push)...
git push origin "%BRANCH%"
if errorlevel 1 goto :fail

echo.
echo ==============================================================================
echo  【完成】同步成功！当前电脑与 GitHub 远端笔记已完全保持最新同步！
echo ==============================================================================
echo.
popd
timeout /t 3 >nul 2>nul || pause
exit /b 0

:fail
echo.
echo ==============================================================================
echo  【失败】同步未完成，请检查上方的 Git 提示信息。
echo ==============================================================================
echo.
popd
pause
exit /b 1
