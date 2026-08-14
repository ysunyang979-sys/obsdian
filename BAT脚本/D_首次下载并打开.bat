@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Obsidian D电脑 - 首次下载并打开笔记

echo ==============================================================================
echo       【Obsidian 学习笔记】D电脑 首次从 GitHub 克隆仓库并打开
echo ==============================================================================
echo.

:: 1. 读取配置文件
call "%~dp000_配置.bat"

:: 2. 检查 Git 是否安装
where git >nul 2>nul
if errorlevel 1 (
  echo [错误] 系统未找到 Git，请先下载安装 Git for Windows (https://git-scm.com/)。
  echo.
  pause
  exit /b 1
)

:: 3. 检查 REPO_URL 是否已配置
echo %REPO_URL% | findstr /i "YOUR_GITHUB_USERNAME" >nul
if not errorlevel 1 (
  echo [错误] REPO_URL 尚未配置！请在 BAT脚本\00_配置.bat 中填入你的 GitHub 仓库地址。
  echo.
  pause
  exit /b 1
)

echo [1/3] 准备本地存放目录：%VAULT_PATH%
if exist "%VAULT_PATH%\.git" (
  echo       检测到该目录已存在 Git 仓库，正在直接拉取最新版本...
  git -C "%VAULT_PATH%" pull --rebase origin "%BRANCH%"
  if errorlevel 1 goto :fail
) else (
  if exist "%VAULT_PATH%" (
    dir /b "%VAULT_PATH%" 2>nul | findstr . >nul
    if not errorlevel 1 (
      echo [错误] 目标目录已存在且非空，但不是 Git 仓库：%VAULT_PATH%
      echo 建议：备份后清空该文件夹，或修改 00_配置.bat 的 VAULT_PATH 为新路径。
      echo.
      pause
      exit /b 1
    )
  )
  for %%I in ("%VAULT_PATH%") do if not exist "%%~dpI" mkdir "%%~dpI"
  echo [2/3] 正在从 GitHub 克隆笔记仓库...
  git clone --branch "%BRANCH%" "%REPO_URL%" "%VAULT_PATH%"
  if errorlevel 1 goto :fail
)

echo.
echo [3/3] 正在唤起 Obsidian 打开笔记库...
start "" "obsidian://open?path=%VAULT_PATH%"

echo.
echo ==============================================================================
echo  【完成】已成功下载笔记并在 Obsidian 中打开！
echo  以后在 D 电脑学习前，只需双击运行 [D_一键打开最新版.bat] 即可自动拉取最新笔记。
echo ==============================================================================
echo.
timeout /t 5 >nul 2>nul || pause
exit /b 0

:fail
echo.
echo ==============================================================================
echo  【失败】克隆或拉取失败！请查看上方的 Git 错误提示（如是否需要登录 GitHub）。
echo ==============================================================================
echo.
pause
exit /b 1
