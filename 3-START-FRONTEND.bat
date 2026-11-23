@echo off
title GraftGuard Frontend Website
cd /d "%~dp0frontend"
echo ========================================================
echo   Starting GraftGuard Frontend Website on Port 5173...
echo ========================================================
npm run dev
pause

