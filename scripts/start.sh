#!/usr/bin/env bash
set -euo pipefail
[ -f .env ] || { echo "Copy .env.example to .env and edit it first."; exit 1; }
docker compose pull
docker compose up -d
DockerStatus=$(docker compose ps --format json 2>/dev/null || true)
echo "$DockerStatus"
echo "Open: http://SERVER_IP:${NEXUSIT_PORT:-5000}/setup"
