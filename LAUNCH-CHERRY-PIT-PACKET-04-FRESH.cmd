@echo off
setlocal
title Cherry Pit Packet 04 Fresh Launcher
cd /d "%~dp0"

echo.
echo ================================================
echo  CHERRY PIT - PACKET 04 FRESH LAUNCHER
echo ================================================
echo Launch folder: %CD%
echo Source file:   %CD%\src\index.html
echo.

where npm >nul 2>nul
if errorlevel 1 (
  echo Node.js and npm are required. Install the current Node.js LTS release, then run this file again.
  pause
  exit /b 1
)

if not exist node_modules (
  echo Installing local dependencies...
  call npm install
  if errorlevel 1 (
    echo Dependency installation failed.
    pause
    exit /b 1
  )
)

echo Launching Packet 04 from this folder now...
call npm start
