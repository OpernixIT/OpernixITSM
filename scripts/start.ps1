$ErrorActionPreference = 'Stop'
if (-not (Test-Path '.env')) { throw 'Copy .env.example to .env and edit it first.' }
docker compose pull
docker compose up -d
docker compose ps
Write-Host 'Open http://SERVER_IP:5000/setup' -ForegroundColor Green
