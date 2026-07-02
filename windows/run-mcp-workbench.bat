@echo off
setlocal
cd /d "%~dp0"

set "REQUIRED_JAVA_MAJOR=22"
where java >nul 2>nul
if errorlevel 1 goto no_java

set "JAVA_VERSION="
for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do (
	set "JAVA_VERSION=%%~v"
	goto parse_java_version
)

:parse_java_version
if not defined JAVA_VERSION goto incompatible_java
for /f "tokens=1,2 delims=.-+" %%a in ("%JAVA_VERSION%") do (
	set "JAVA_MAJOR=%%a"
	if "%%a"=="1" set "JAVA_MAJOR=%%b"
)
if not defined JAVA_MAJOR goto incompatible_java
set /a JAVA_MAJOR_NUMBER=%JAVA_MAJOR% >nul 2>nul
if errorlevel 1 goto incompatible_java
if %JAVA_MAJOR_NUMBER% LSS %REQUIRED_JAVA_MAJOR% goto incompatible_java

java -jar mcp-workbench-launcher.jar %*
exit /b %ERRORLEVEL%

:no_java
echo MCP Workbench requires Java %REQUIRED_JAVA_MAJOR% or newer, but Java was not found on PATH.
echo Install Java %REQUIRED_JAVA_MAJOR% or newer, or download the Windows with-JRE zip.
pause
exit /b 1

:incompatible_java
echo MCP Workbench requires Java %REQUIRED_JAVA_MAJOR% or newer.
if defined JAVA_VERSION echo Detected Java version: %JAVA_VERSION%.
echo Install Java %REQUIRED_JAVA_MAJOR% or newer, or download the Windows with-JRE zip.
pause
exit /b 1
