@echo off
chcp 65001 >nul
title Obsidian - Batch Convert Images to WebP

echo ==============================================================================
echo       Obsidian 学习笔记: 批量将附件图片转为 WebP 压缩格式
echo ==============================================================================
echo.

call "%~dp000_config.bat"

if not exist "%VAULT_PATH%" (
    echo [错误] 找不到 Obsidian 目录
    pause
    exit /b 1
)

python "%~dp0convert_webp.py" "%VAULT_PATH%"

echo.
echo ==============================================================================
echo  处理完成！
echo ==============================================================================
echo.
pause
