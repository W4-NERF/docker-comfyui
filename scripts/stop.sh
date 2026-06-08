#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "Stopping ComfyUI stack..."
docker compose down
echo "ComfyUI stack stopped."
