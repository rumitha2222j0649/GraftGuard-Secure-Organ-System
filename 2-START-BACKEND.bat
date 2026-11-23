@echo off
title GraftGuard Server (Port 3000 & 5000)
cd /d "%~dp0backend"

echo ========================================================
echo   Clearing any old process on Port 5000 and 3000...
echo ========================================================
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :5000 ^| findstr LISTENING') do taskkill /F /PID %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :3000 ^| findstr LISTENING') do taskkill /F /PID %%a >nul 2>&1

echo ========================================================
echo   Starting GraftGuard Server on Port 5000 and 3000...
echo ========================================================
npm start
pause
