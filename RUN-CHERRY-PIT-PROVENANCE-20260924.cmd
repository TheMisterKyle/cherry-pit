@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
cd /d "%ROOT%" || (
  echo ERROR: Unable to change to launcher directory.
  exit /b 1
)

echo.
echo CHERRY PIT - PROVENANCE DIAGNOSTIC 2026-09-24
echo Checkout root: %CD%
echo.

if not exist ".git" (
  echo ERROR: .git is missing. This launcher must run from a Git checkout.
  exit /b 1
)
if not exist "package.json" (
  echo ERROR: package.json is missing.
  exit /b 1
)
if not exist "src\main.js" (
  echo ERROR: Expected Electron entrypoint src\main.js is missing.
  exit /b 1
)
if not exist "src\index.html" (
  echo ERROR: Expected renderer src\index.html is missing.
  exit /b 1
)
if not exist "src\styles.css" (
  echo ERROR: Expected renderer stylesheet src\styles.css is missing.
  exit /b 1
)
if not exist "node_modules\electron\dist\electron.exe" (
  echo ERROR: Local Electron is missing at node_modules\electron\dist\electron.exe.
  echo        This diagnostic will not install dependencies or use a global Electron.
  exit /b 1
)

for /f %%I in ('git rev-parse --short HEAD 2^>nul') do set "PROVENANCE_SHA=%%I"
if not defined PROVENANCE_SHA (
  echo ERROR: Unable to resolve git HEAD.
  exit /b 1
)
for /f %%I in ('powershell -NoProfile -Command "[DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')"') do set "PROVENANCE_UTC=%%I"

set "CHERRY_PIT_PROVENANCE_ROOT=%CD%"
set "CHERRY_PIT_PROVENANCE_SHA=%PROVENANCE_SHA%"
set "CHERRY_PIT_PROVENANCE_UTC=%PROVENANCE_UTC%"
set "ELECTRON_EXE=%CD%\node_modules\electron\dist\electron.exe"
set "LOG_DIR=%CD%\diagnostics\provenance"
set "LOG_FILE=%LOG_DIR%\provenance-%PROVENANCE_UTC::=-%.log"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$root=$env:CHERRY_PIT_PROVENANCE_ROOT; $log=$env:LOG_FILE; $electron=$env:ELECTRON_EXE; $node=(Get-Command node.exe -ErrorAction SilentlyContinue).Source; $npm=(Get-Command npm.cmd -ErrorAction SilentlyContinue).Source; $hashes=@('src\main.js','src\index.html','src\styles.css') | ForEach-Object { $h=Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $root $_); ('SHA256 {0}  {1}' -f $_,$h.Hash) }; @('Cherry Pit provenance diagnostic','Start UTC: ' + $env:CHERRY_PIT_PROVENANCE_UTC,'Resolved root: ' + $root,'Git HEAD: ' + (git -C $root rev-parse HEAD),'Git status --porcelain=v1:',(git -C $root status --porcelain=v1),'Git remote -v:',(git -C $root remote -v),'node.exe path: ' + $node,'npm.cmd path: ' + $npm,'Local Electron executable invoked: ' + $electron,'Local Electron script: ' + (Join-Path $root 'node_modules\.bin\electron.cmd'),'Electron entrypoint: ' + (Join-Path $root 'src\main.js'),'Renderer HTML: ' + (Join-Path $root 'src\index.html'),'Renderer CSS: ' + (Join-Path $root 'src\styles.css'),'Exact launch command: "' + $electron + '" "' + $root + '"','Source hashes:',$hashes) | Set-Content -LiteralPath $log -Encoding UTF8"
if errorlevel 1 (
  echo ERROR: Could not create provenance log.
  exit /b 1
)

echo Git commit: %PROVENANCE_SHA%
echo Log file:   %LOG_FILE%
echo.
echo Stopping only prior Electron processes launched from this checkout...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$root=[regex]::Escape($env:CHERRY_PIT_PROVENANCE_ROOT); Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'electron.exe' -and $_.CommandLine -and $_.CommandLine -match $root } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force; 'Stopped PID ' + $_.ProcessId }" >> "%LOG_FILE%" 2>&1

echo Launching local Electron directly:
echo "%ELECTRON_EXE%" "%CD%"
echo.
"%ELECTRON_EXE%" "%CD%" >> "%LOG_FILE%" 2>&1

echo.
echo Cherry Pit exited.
echo Provenance log: %LOG_FILE%
echo.
pause
endlocal
