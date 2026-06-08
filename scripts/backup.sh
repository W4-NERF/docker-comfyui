#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="${BACKUP_DIR}/comfyui_${TIMESTAMP}.tar.gz"

mkdir -p "${BACKUP_DIR}"

echo "Backing up ComfyUI data to ${BACKUP_PATH}..."

tar -czf "${BACKUP_PATH}" \
    --exclude='*.safetensors' \
    --exclude='*.ckpt' \
    --exclude='*.pt' \
    --exclude='*.pth' \
    --exclude='*.bin' \
    --exclude='.git' \
    data/user_data \
    data/custom_nodes \
    data/output \
    2>/dev/null

echo "Backup complete: ${BACKUP_PATH}"
echo "Note: Model weights (*.safetensors, *.ckpt, etc.) are excluded by default."
echo "      Add --include-models flag to include them (results in a very large archive)."
