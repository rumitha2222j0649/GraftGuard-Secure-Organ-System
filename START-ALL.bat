@echo off
title GraftGuard All-In-One Launcher
cd /d "%~dp0"
cls
echo ======================================================================
echo          GRAFTGUARD - SECURE ORGAN SYSTEM ALL-IN-ONE
echo ======================================================================
echo.

echo [1/3] Starting Database...
start "GraftGuard MongoDB" /min cmd /k "1-START-MONGODB.bat"

timeout /t 2 /nobreak >nul

echo [2/3] Starting Backend Server...
start "GraftGuard Backend" cmd /k "2-START-BACKEND.bat"

timeout /t 3 /nobreak >nul

echo [3/3] Starting Frontend Website...
start "GraftGuard Frontend" cmd /k "3-START-FRONTEND.bat"

timeout /t 3 /nobreak >nul

echo Opening Browser at http://localhost:5173 ...
start http://localhost:5173

echo.
echo ======================================================================
echo   All 3 services are now running!
echo   Website: http://localhost:5173
echo ======================================================================
pause

