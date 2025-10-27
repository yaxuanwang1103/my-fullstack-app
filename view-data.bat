@echo off
chcp 65001 >nul
title 查看数据库数据

echo ========================================
echo    数据库数据查看
echo ========================================
echo.
echo 选择要执行的操作：
echo.
echo 1. 查看所有任务
echo 2. 查看任务统计
echo 3. 查看最近10条任务
echo 4. 按类别统计
echo 5. 按优先级统计
echo 6. 进入 PostgreSQL 命令行
echo 0. 退出
echo.

set /p choice=请输入选项 (0-6): 

if "%choice%"=="1" (
    echo.
    echo 📊 所有任务：
    docker exec -it todoapp-postgres psql -U todouser -d todoapp -c "SELECT id, text, category, priority, \"createdAt\" FROM todos ORDER BY \"createdAt\" DESC;"
    pause
)

if "%choice%"=="2" (
    echo.
    echo 📊 任务统计：
    docker exec -it todoapp-postgres psql -U todouser -d todoapp -c "SELECT COUNT(*) as total FROM todos;"
    pause
)

if "%choice%"=="3" (
    echo.
    echo 📊 最近10条任务：
    docker exec -it todoapp-postgres psql -U todouser -d todoapp -c "SELECT id, text, category, priority, \"createdAt\" FROM todos ORDER BY \"createdAt\" DESC LIMIT 10;"
    pause
)

if "%choice%"=="4" (
    echo.
    echo 📊 按类别统计：
    docker exec -it todoapp-postgres psql -U todouser -d todoapp -c "SELECT category, COUNT(*) as count FROM todos GROUP BY category;"
    pause
)

if "%choice%"=="5" (
    echo.
    echo 📊 按优先级统计：
    docker exec -it todoapp-postgres psql -U todouser -d todoapp -c "SELECT priority, COUNT(*) as count FROM todos GROUP BY priority;"
    pause
)

if "%choice%"=="6" (
    echo.
    echo 💻 进入 PostgreSQL 命令行...
    echo 提示：输入 \q 退出
    echo.
    docker exec -it todoapp-postgres psql -U todouser -d todoapp
)

if "%choice%"=="0" (
    exit
)
