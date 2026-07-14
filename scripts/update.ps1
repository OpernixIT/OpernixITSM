$ErrorActionPreference = 'Stop'
if (-not (Test-Path '.env')) { throw '.env is missing.' }
docker compose pull
docker compose up -d --remove-orphans
docker image prune -f
Write-Host 'OpernixIT updated. Database volumes were preserved.' -ForegroundColor Green
