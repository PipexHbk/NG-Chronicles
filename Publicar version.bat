@echo off
rem Publica el estado actual del proyecto como una version nueva del juego.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0publicar_version.ps1" %*
echo.
pause
