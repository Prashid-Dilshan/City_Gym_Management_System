@echo off
title City Gym Management System

cd /d "%~dp0bin"

call startup.bat

timeout /t 5 >nul

start http://localhost:8080/CityGym

echo.
echo Browser close karala me window eka close karanna...
pause

call shutdown.bat
exit