@echo off
chcp 65001 >nul
title Obsidian 笔记库体检

echo ==============================================================================
echo       Obsidian 学习笔记: 体检工具 (大文件检查与冲突扫描)
echo ==============================================================================
echo.

call "%~dp000_config.bat"

if not exist "%VAULT_PATH%" (
    echo [错误] Vault 目录不存在：%VAULT_PATH%
    pause
    exit /b 1
)

echo [1/2] 正在扫描库内大于 50MB 的大文件...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%VAULT_PATH%' -File -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt 50MB -and $_.FullName -notmatch '\.git\' } | Select-Object @{N='大小(MB)';E={[math]::Round($_.Length/1MB,1)}}, FullName | Format-Table -AutoSize"
echo 大文件扫描完成

echo.
echo [2/2] 正在扫描是否存在未解决的 Git 冲突标记...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%VAULT_PATH%' -Filter '*.md' -Recurse -File -ErrorAction SilentlyContinue | Select-String -Pattern '<<<<<<<' -SimpleMatch | Select-Object -Unique Path | Format-Table -AutoSize"
echo 冲突标记扫描完成

echo.
echo ==============================================================================
echo  检查完毕。
echo ==============================================================================
echo.
pause
