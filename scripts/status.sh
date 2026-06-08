#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "=== Container status ==="
docker compose ps

echo ""
echo "=== Resource usage ==="
docker stats --no-stream comfyui 2>/dev/null || echo "Container not running."
