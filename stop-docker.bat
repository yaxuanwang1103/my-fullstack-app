@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   🛑 停止 Docker 容器
echo ========================================
echo.

docker-compose down

if %errorlevel% equ 0 (
    echo.
    echo ✅ 所有容器已停止
) else (
    echo.
    echo ❌ 停止失败
)

echo.
pause
