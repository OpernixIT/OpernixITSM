$ErrorActionPreference = 'Stop'
if (-not (Test-Path '.env')) { throw 'Copy .env.example to .env and edit it first.' }
$port = 5000
Get-Content '.env' | ForEach-Object {
  if ($_ -match '^OPERNIXIT_PORT=(.+)$') { $port = $Matches[1] }
}
docker compose pull
docker compose up -d
docker compose ps
Write-Host "Open http://SERVER_IP:$port/setup" -ForegroundColor Green
