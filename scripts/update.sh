#!/usr/bin/env bash
set -euo pipefail
[ -f .env ] || { echo ".env is missing."; exit 1; }
docker compose pull
docker compose up -d --remove-orphans
docker image prune -f
echo "NexusIT containers updated. Database volumes were preserved."
