@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   🔍 端口占用检查工具
echo ========================================
echo.

echo 检查项目所需端口...
echo.

echo 【前端 - 5173】
netstat -ano | findstr :5173 | findstr LISTENING
if errorlevel 1 (
    echo ✅ 端口 5173 可用
) else (
    echo ❌ 端口 5173 被占用
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5173 ^| findstr LISTENING') do (
        echo    进程 ID: %%a
        tasklist /FI "PID eq %%a" /FO TABLE /NH
    )
)
echo.

echo 【后端A - 3000】
netstat -ano | findstr :3000 | findstr LISTENING
if errorlevel 1 (
    echo ✅ 端口 3000 可用
) else (
    echo ❌ 端口 3000 被占用
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000 ^| findstr LISTENING') do (
        echo    进程 ID: %%a
        tasklist /FI "PID eq %%a" /FO TABLE /NH
    )
)
echo.

echo 【后端B - 4000】
netstat -ano | findstr :4000 | findstr LISTENING
if errorlevel 1 (
    echo ✅ 端口 4000 可用
) else (
    echo ❌ 端口 4000 被占用
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :4000 ^| findstr LISTENING') do (
        echo    进程 ID: %%a
        tasklist /FI "PID eq %%a" /FO TABLE /NH
    )
)
echo.

echo 【PostgreSQL - 5433】
netstat -ano | findstr :5433 | findstr LISTENING
if errorlevel 1 (
    echo ✅ 端口 5433 可用
) else (
    echo ❌ 端口 5433 被占用
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5433 ^| findstr LISTENING') do (
        echo    进程 ID: %%a
        tasklist /FI "PID eq %%a" /FO TABLE /NH
    )
)
echo.

echo ========================================
echo 提示：
echo - 如果端口被占用，可以运行 start-docker.bat 自动处理
echo - 或手动停止占用进程：taskkill /F /PID [进程ID]
echo ========================================
echo.
pause
