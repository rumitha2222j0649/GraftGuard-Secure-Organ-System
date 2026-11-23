@echo off
title GraftGuard All-In-One Launcher
cd /d "%~dp0"
cls
echo ======================================================================
echo          GRAFTGUARD - SECURE ORGAN SYSTEM (PORT 3000)
echo ======================================================================
echo.

echo [1/2] Starting Database...
start "GraftGuard MongoDB" /min "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" --dbpath "%~dp0backend\data\db" --bind_ip 127.0.0.1

timeout /t 2 /nobreak >nul

echo [2/2] Starting GraftGuard Full-Stack Server on Port 3000...
cd /d "%~dp0backend"
start http://localhost:3000
npm start
pause
