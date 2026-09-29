# Carga backend/.env y arranca Spring Boot.
# Spring Boot NO lee archivos .env de forma nativa: sin esto, JWT_SECRET
# falta en cada terminal nueva y la app muere con
# "JWT_SECRET debe contener al menos 32 bytes".

$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

$envFile = Join-Path $PSScriptRoot '.env'
if (-not (Test-Path -LiteralPath $envFile)) {
    Write-Host "No existe backend/.env" -ForegroundColor Red
    Write-Host "Copia la plantilla y genera un secreto:" -ForegroundColor Yellow
    Write-Host "  Copy-Item .env.example .env" -ForegroundColor Yellow
    Write-Host "  (reemplaza JWT_SECRET por 32+ caracteres aleatorios)" -ForegroundColor Yellow
    exit 1
}

Get-Content -LiteralPath $envFile -Encoding UTF8 | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq '' -or $line.StartsWith('#')) { return }

    $separator = $line.IndexOf('=')
    if ($separator -lt 1) { return }

    $key = $line.Substring(0, $separator).Trim()
    $value = $line.Substring($separator + 1).Trim().Trim('"').Trim("'")
    Set-Item -Path "env:$key" -Value $value
}

if ($env:JWT_SECRET.Length -lt 32) {
    Write-Host "JWT_SECRET en .env tiene menos de 32 bytes" -ForegroundColor Red
    exit 1
}

Write-Host "Variables cargadas desde .env" -ForegroundColor DarkGray
Write-Host "  JWT_SECRET   : $($env:JWT_SECRET.Length) bytes" -ForegroundColor DarkGray
Write-Host "  DB           : $env:DB_USER@$env:DB_HOST`:$env:DB_PORT/$env:DB_NAME" -ForegroundColor DarkGray
Write-Host "  CORS         : $env:CORS_ALLOWED_ORIGINS" -ForegroundColor DarkGray
Write-Host "Swagger       : http://localhost:8080/swagger-ui.html" -ForegroundColor DarkGray
Write-Host ""

& .\mvnw.cmd spring-boot:run
