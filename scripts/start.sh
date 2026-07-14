#!/usr/bin/env bash
set -euo pipefail
[ -f .env ] || { echo "Copy .env.example to .env and edit it first."; exit 1; }
set -a
source .env
set +a
docker compose pull
docker compose up -d
docker compose ps
echo "Open: http://SERVER_IP:${OPERNIXIT_PORT:-5000}/setup"
