@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Obsidian A电脑 - 首次初始化并上传至 GitHub

echo ==============================================================================
echo       【Obsidian 学习笔记】A电脑 首次初始化并推送到 GitHub 远程仓库
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

:: 3. 检查 Vault 路径
if not exist "%VAULT_PATH%" (
  echo [错误] 找不到 Obsidian 笔记库目录：%VAULT_PATH%
  echo 请在 BAT脚本\00_配置.bat 中修改 VAULT_PATH 为正确的笔记库绝对路径。
  echo.
  pause
  exit /b 1
)

:: 4. 检查 REPO_URL 是否已填写
echo %REPO_URL% | findstr /i "YOUR_GITHUB_USERNAME" >nul
if not errorlevel 1 (
  echo [提示] 检测到 REPO_URL 仍为默认占位符。
  echo 请先在 GitHub 创建一个 Private 仓库，并将仓库地址填入 BAT脚本\00_配置.bat 中！
  echo.
  pause
  exit /b 1
)

echo [1/5] 检查并部署 .gitignore 文件...
if not exist "%VAULT_PATH%\.gitignore" (
  if exist "%~dp0..\.gitignore" (
    copy /y "%~dp0..\.gitignore" "%VAULT_PATH%\.gitignore" >nul
    echo       已自动将标准 .gitignore 复制到笔记库根目录。
  ) else (
    (
      echo .obsidian/workspace.json
      echo .obsidian/workspace-mobile.json
      echo .obsidian/cache/
      echo .trash/
      echo .DS_Store
      echo Thumbs.db
      echo desktop.ini
      echo *.tmp
    ) > "%VAULT_PATH%\.gitignore"
    echo       已自动生成标准 .gitignore 文件。
  )
) else (
  echo       .gitignore 已存在。
)

echo.
echo [2/5] 进入笔记目录并初始化 Git...
pushd "%VAULT_PATH%"

if not exist ".git" (
  git init
  echo       已完成本地 Git 仓库初始化。
) else (
  echo       本地 Git 仓库已存在。
)

:: 强制切换为指定主分支名称（main）
git checkout -B "%BRANCH%" >nul 2>nul || git branch -M "%BRANCH%"

echo.
echo [3/5] 配置远程仓库关联...
git remote get-url origin >nul 2>nul
if errorlevel 1 (
  git remote add origin "%REPO_URL%"
  echo       已关联远程仓库：%REPO_URL%
) else (
  git remote set-url origin "%REPO_URL%"
  echo       已更新远程仓库为：%REPO_URL%
)

echo.
echo [4/5] 暂存并提交本地所有笔记文件...
git add -A
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "feat: Initial Obsidian vault upload (%DATE% %TIME%)"
  echo       已完成本地 commit 提交。
) else (
  echo       当前笔记没有需要提交的新变动。
)

echo.
echo [5/5] 正在推送到 GitHub (%BRANCH% 分支)...
echo       (如果是第一次连接 GitHub，可能会弹出浏览器或凭据登录窗口，请按提示完成授权)
echo.

git push -u origin "%BRANCH%"
if errorlevel 1 goto :fail

echo.
echo ==============================================================================
echo  【成功】首次上传完成！你的全部笔记已安全同步到 GitHub。
echo ==============================================================================
echo.
popd
pause
exit /b 0

:fail
echo.
echo ==============================================================================
echo  【失败】推送到 GitHub 失败！常见原因及解决方法：
echo  1. GitHub 上新建的仓库不是空仓库（包含了 README/.gitignore）：
echo     解决：可在命令行执行 git pull origin %BRANCH% --allow-unrelated-histories 后再推。
echo  2. 网络连接 GitHub 超时 / 被拦截：
echo     解决：开启代理工具，或配置 SSH 密钥连接。
echo  3. GitHub 身份验证未通过：
echo     解决：检查 Git 登录状态，或在弹出窗口中完成授权。
echo ==============================================================================
echo.
popd
pause
exit /b 1
