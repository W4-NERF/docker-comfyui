#!/bin/bash
set -euo pipefail

COMFYUI_DIR="/comfyui"
MANAGER_DIR="${COMFYUI_DIR}/custom_nodes/ComfyUI-Manager"
DATA_DIRS=("models" "output" "custom_nodes" "user_data")
# Empty = clone Manager's default branch (current behavior). Set to a tag/
# branch/commit to pin it, same idea as COMFYUI_VERSION. Only affects a fresh
# install — it doesn't move an already-cloned Manager checkout.
COMFYUI_MANAGER_REF="${COMFYUI_MANAGER_REF:-}"

# Ensure data directories exist with correct ownership.
# Only chown the top-level data dirs (not -R) — a recursive chown over a
# multi-hundred-GB models/ bind-mount on every start is brutally slow.
for dir in "${DATA_DIRS[@]}"; do
    mkdir -p "${COMFYUI_DIR}/${dir}"
    chown comfyui:comfyui "${COMFYUI_DIR}/${dir}"
done

# Install / update ComfyUI Manager
if [ ! -d "$MANAGER_DIR/.git" ]; then
    echo "[entrypoint] Installing ComfyUI Manager..."
    if [ -n "$COMFYUI_MANAGER_REF" ]; then
        gosu comfyui git clone --depth 1 --branch "$COMFYUI_MANAGER_REF" \
            https://github.com/ltdrdata/ComfyUI-Manager.git "$MANAGER_DIR"
    else
        gosu comfyui git clone --depth 1 \
            https://github.com/ltdrdata/ComfyUI-Manager.git "$MANAGER_DIR"
    fi
fi

# Always ensure dependencies are installed (survives image rebuilds). Failures
# are non-fatal (Manager may already have what it needs from the image build)
# but are logged instead of silently discarded, so a real problem — network
# down, disk full, a broken requirements pin — shows up in `make logs`.
gosu comfyui pip install --no-cache-dir --disable-pip-version-check -r "$MANAGER_DIR/requirements.txt" \
    || echo "[entrypoint] warning: ComfyUI-Manager dependency install failed; continuing with what's already installed" >&2

# Ensure openai-agents is available for ComfyUI-Copilot (survives container
# recreation). OPENAI_AGENTS_PACKAGE is baked in from the image build (see
# Dockerfile) so a runtime reinstall doesn't drift away from a pinned version.
gosu comfyui pip install --no-cache-dir --disable-pip-version-check "${OPENAI_AGENTS_PACKAGE:-openai-agents}" \
    || echo "[entrypoint] warning: openai-agents install failed; ComfyUI-Copilot may not work" >&2

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
    ${COMFYUI_EXTRA_ARGS:-}
