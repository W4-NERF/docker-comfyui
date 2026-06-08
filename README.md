# docker-comfyui

A containerized [ComfyUI](https://github.com/comfyanonymous/ComfyUI) stack with GPU passthrough, [ComfyUI-Manager](https://github.com/ltdrdata/ComfyUI-Manager), and one-command management via Docker Compose.

## Quick Start

```bash
# Clone and enter
git clone https://github.com/W4-NERF/docker-comfyui.git
cd docker-comfyui

# Configure
cp .env.example .env
# Edit .env to match your paths and preferences

# Start
make up
```

ComfyUI will be available at `http://localhost:8188`.

## Requirements

- Docker with `nvidia-container-toolkit` installed
- `docker compose` (or `docker-compose`)
- NVIDIA GPU with proprietary drivers
- At least 16GB VRAM recommended (for large FLUX/ACE models)

## Directory Layout

```
.
├── .env                 # Configuration (secrets, paths, GPU, args)
├── docker-compose.yml   # Service definition
├── Dockerfile           # Image build
├── docker-entrypoint.sh # Container startup script
├── Makefile             # Common commands
├── scripts/             # Helper scripts
└── data/                # Persistent data (volume mount target)
    ├── models/          # Checkpoints, UNet, VAE, text encoders
    ├── output/          # Generated images
    ├── custom_nodes/    # ComfyUI custom nodes
    └── user_data/       # ComfyUI user data & Manager cache
```

## Configuration

Edit `.env` to set:

| Variable | Default | Description |
|---|---|---|
| `COMFYUI_VERSION` | `v0.24.1` | ComfyUI git tag |
| `COMFYUI_PORT` | `8188` | Host port |
| `COMFYUI_EXTRA_ARGS` | `--lowvram` | CLI flags (see `main.py --help`) |
| `COMFYUI_UID` / `COMFYUI_GID` | `1000` | Container user/group |
| `MODELS_PATH` | `./data/models` | Host model directory |
| `OUTPUT_PATH` | `./data/output` | Host output directory |

### VRAM Modes

Set `COMFYUI_EXTRA_ARGS` to control GPU memory usage:

- *(empty)* — Normal VRAM (default, swaps models between GPU/CPU)
- `--lowvram` — Layer-level offloading, for large models on 16GB cards
- `--highvram` — Keep everything on GPU (needs 24GB+)

## Usage

```bash
make start      # Start container
make stop       # Stop container
make logs       # Follow logs
make restart    # Restart container
make exec       # Open shell inside container
make backup     # Backup data directory
make status     # Check container status
```

Or use docker-compose directly:

```bash
docker compose up -d
docker compose down
docker compose logs -f
```

## Models

Place model files in the appropriate subdirectory under `data/models/`:

```
data/models/
├── checkpoints/       # SD 1.5 / SDXL checkpoints
├── diffusion_models/  # UNet / diffusion models (FLUX, Z-Image, ACE, etc.)
├── text_encoders/     # CLIP / text encoder models
├── vae/               # VAE models
└── unet/              # Alternative UNet directory
```

### Recommended Models

| Workflow | Text Encoder | UNet | VAE |
|---|---|---|---|
| Anima | `qwen_3_06b_base.safetensors` | `anima-base-v1.0.safetensors` | `qwen_image_vae.safetensors` |
| Z-Image Base | `qwen_3_4b.safetensors` | `z_image_bf16.safetensors` | `ae.safetensors` |
| AceStep Audio | `qwen_0.6b_ace15.safetensors` | `acestep_v1.5_turbo.safetensors` | — |

## ComfyUI Manager

[ComfyUI-Manager](https://github.com/ltdrdata/ComfyUI-Manager) is pre-installed and configured with `network_mode = public`. Use it to:

- Browse and install custom nodes from the UI
- Check for missing custom nodes in loaded workflows
- Update custom nodes

> **Note:** Missing node detection is manual — click **Check Missing** in the Manager dialog. Built-in workflow templates use only default nodes and won't show any.

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---|---|---|
| OOM on UNET load | `--highvram` with models totalling >16GB | Set `COMFYUI_EXTRA_ARGS=--lowvram` |
| OOM during LM sampling | KV cache exceeds VRAM | Use smaller text encoder variant |
| `SafetensorError: header too large` | Model file truncated/corrupted | Re-download the file |
| `ModuleNotFoundError: No module named 'agents'` | ComfyUI-Copilot dependency missing | `pip install openai-agents` in container |
| Permission errors on volume mounts | UID/GID mismatch | Match `COMFYUI_UID` to your host user ID |

## Disclaimer

This stack is provided **as-is**. It's a convenience wrapper, not a hardened appliance.

- **No guarantees** — not of functionality, not of security, not of fitness for any
  purpose. It works on my machine. That is the full extent of the promise.
- **Hardening is a starting point, not a finish line.** The defaults bind ComfyUI to
  `127.0.0.1` and run the app as a non-root user, but that does not make it "secure."
  If you expose this beyond localhost, put it behind a reverse proxy with
  authentication, review the ComfyUI-Manager `security_level`, and harden the host
  and container to your own requirements.
- **ComfyUI-Manager can execute arbitrary code** — installing a custom node runs
  whatever that node ships. Only install nodes you trust, and never expose the UI to
  an untrusted network.
- **You run it, you own it.** Back up your own data, vet your own models and nodes,
  and understand what you're deploying. Everyone for themselves.

See [LICENSE](./LICENSE) for the formal terms (MIT — which already disclaims warranty,
this section just says it in plain language).

## License

MIT
