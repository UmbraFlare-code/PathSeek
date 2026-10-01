@echo off
REM Arranca el backend cargando backend/.env (via run-local.ps1).
REM No requiere cambiar la ExecutionPolicy: aplica Bypass solo a esta invocacion.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-local.ps1" %*
