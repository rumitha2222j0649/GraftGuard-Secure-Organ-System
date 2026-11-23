@echo off
title GraftGuard MongoDB Database
echo ========================================================
echo   Starting Local MongoDB Server on Port 27017...
echo ========================================================
"C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" --dbpath "%~dp0backend\data\db" --bind_ip 127.0.0.1
pause

