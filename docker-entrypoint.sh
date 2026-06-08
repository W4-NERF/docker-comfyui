#!/bin/bash
set -euo pipefail

COMFYUI_DIR="/comfyui"
MANAGER_DIR="${COMFYUI_DIR}/custom_nodes/ComfyUI-Manager"
DATA_DIRS=("models" "output" "custom_nodes" "user_data")

# Ensure data directories exist with correct ownership
for dir in "${DATA_DIRS[@]}"; do
    mkdir -p "${COMFYUI_DIR}/${dir}"
done
chown -R comfyui:comfyui "${COMFYUI_DIR}"

# Install / update ComfyUI Manager
if [ ! -d "$MANAGER_DIR/.git" ]; then
    echo "[entrypoint] Installing ComfyUI Manager..."
    gosu comfyui git clone --depth 1 \
        https://github.com/ltdrdata/ComfyUI-Manager.git "$MANAGER_DIR"
fi

# Always ensure dependencies are installed (survives image rebuilds)
gosu comfyui pip install --no-cache-dir -r "$MANAGER_DIR/requirements.txt" 2>/dev/null || true

# Ensure openai-agents is available for ComfyUI-Copilot (survives container recreation)
gosu comfyui pip install --no-cache-dir openai-agents 2>/dev/null || true

# Seed Manager config so missing-nodes detection works immediately
MANAGER_STORE="${COMFYUI_DIR}/user_data/__manager"
if [ ! -f "$MANAGER_STORE/config.ini" ]; then
    echo "[entrypoint] Creating default ComfyUI-Manager config..."
    mkdir -p "$MANAGER_STORE"
    # security_level = normal lets you install nodes from the UI. Fine while the
    # port is bound to localhost. If you ever expose the UI on a network, tighten
    # this (e.g. normal- or strong) — check current ComfyUI-Manager docs for the
    # exact level semantics, they've changed across versions.
    cat > "$MANAGER_STORE/config.ini" <<'INI'
[default]
network_mode = public
security_level = normal
component_policy = workflow
update_policy = stable-comfyui
channel_url = https://raw.githubusercontent.com/ltdrdata/ComfyUI-Manager/main
preview_method = auto
db_mode = cache
file_logging = True
model_download_by_agent = False
INI
    chown -R comfyui:comfyui "$MANAGER_STORE"
fi

echo "[entrypoint] Starting ComfyUI..."
# --listen 0.0.0.0 is correct here: it binds *inside* the container so Docker's
# port mapping works. Host-side exposure is controlled by BIND_ADDR in compose.
exec gosu comfyui python /comfyui/main.py \
    --listen 0.0.0.0 \
    --port 8188 \
    $COMFYUI_EXTRA_ARGS
