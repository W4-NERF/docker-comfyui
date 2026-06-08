#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "Building and starting ComfyUI stack..."
docker compose up --build -d
echo "ComfyUI is starting. Access it at http://localhost:${COMFYUI_PORT:-8188}"
