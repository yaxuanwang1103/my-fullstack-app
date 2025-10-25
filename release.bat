@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   📦 版本发布助手
echo ========================================
echo.

REM 读取当前版本
set /p CURRENT_VERSION=<VERSION
echo 当前版本: %CURRENT_VERSION%
echo.

echo 请选择发布类型：
echo 1. Patch (修订号 +1) - Bug 修复
echo 2. Minor (次版本号 +1) - 新功能
echo 3. Major (主版本号 +1) - 重大更新
echo 4. 自定义版本号
echo 5. 取消
echo.

set /p CHOICE=请输入选项 (1-5): 

if "%CHOICE%"=="1" goto PATCH
if "%CHOICE%"=="2" goto MINOR
if "%CHOICE%"=="3" goto MAJOR
if "%CHOICE%"=="4" goto CUSTOM
if "%CHOICE%"=="5" goto END

:PATCH
echo.
echo 📝 Patch 发布 - 修复 Bug
set /p NEW_VERSION=请输入新版本号 (例如: 2.0.1): 
goto CONFIRM

:MINOR
echo.
echo ✨ Minor 发布 - 新增功能
set /p NEW_VERSION=请输入新版本号 (例如: 2.1.0): 
goto CONFIRM

:MAJOR
echo.
echo 🎉 Major 发布 - 重大更新
set /p NEW_VERSION=请输入新版本号 (例如: 3.0.0): 
goto CONFIRM

:CUSTOM
echo.
echo 🔧 自定义版本号
set /p NEW_VERSION=请输入新版本号: 
goto CONFIRM

:CONFIRM
echo.
echo ========================================
echo 版本更新确认
echo ========================================
echo 当前版本: %CURRENT_VERSION%
echo 新版本:   %NEW_VERSION%
echo.
set /p CONFIRM=确认发布? (Y/N): 

if /i not "%CONFIRM%"=="Y" goto END

echo.
echo 🚀 开始发布流程...
echo.

REM 1. 更新 VERSION 文件
echo %NEW_VERSION%> VERSION
echo ✅ 已更新 VERSION 文件

REM 2. 提示更新 CHANGELOG
echo.
echo ⚠️  请手动更新以下文件：
echo    1. CHANGELOG.md - 添加新版本的变更说明
echo    2. package.json - 更新版本号（如需要）
echo.
echo 📝 CHANGELOG.md 模板：
echo.
echo ## [%NEW_VERSION%] - %date:~0,10%
echo.
echo ### ✨ 新增
echo - 新功能描述
echo.
echo ### 🔧 修复
echo - Bug 修复描述
echo.
echo ### 📚 文档
echo - 文档更新
echo.
pause

echo.
echo 📋 接下来的步骤：
echo.
echo 1. git add .
echo 2. git commit -m "chore: 发布 v%NEW_VERSION%"
echo 3. git tag -a v%NEW_VERSION% -m "版本 %NEW_VERSION%"
echo 4. git push origin main --tags
echo.
set /p AUTO_GIT=是否自动执行 Git 操作? (Y/N): 

if /i not "%AUTO_GIT%"=="Y" goto MANUAL

echo.
echo 🔄 执行 Git 操作...
echo.

git add .
git commit -m "chore: 发布 v%NEW_VERSION%"
git tag -a v%NEW_VERSION% -m "版本 %NEW_VERSION%"
git push origin main --tags

if %errorlevel% equ 0 (
    echo.
    echo ✅ 发布成功！
    echo.
    echo 📱 下一步：
    echo    访问 GitHub 创建 Release
    echo    https://github.com/你的用户名/my-fullstack-app/releases/new
) else (
    echo.
    echo ❌ Git 操作失败，请手动执行
)

goto END

:MANUAL
echo.
echo 📋 请手动执行以下命令：
echo.
echo git add .
echo git commit -m "chore: 发布 v%NEW_VERSION%"
echo git tag -a v%NEW_VERSION% -m "版本 %NEW_VERSION%"
echo git push origin main --tags
echo.

:END
echo.
pause
