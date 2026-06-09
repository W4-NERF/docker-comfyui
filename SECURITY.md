# Security Policy

This project is a thin Docker wrapper around [ComfyUI](https://github.com/comfyanonymous/ComfyUI) and [ComfyUI-Manager](https://github.com/ltdrdata/ComfyUI-Manager). It is maintained on a best-effort basis. Please read the [Disclaimer](./README.md#disclaimer) in the README before relying on it for anything sensitive.

## Supported Versions

Only the latest commit on `main` is supported. There are no maintained release branches.

| Version | Supported |
|---|---|
| `main` (latest) | ✅ |
| Older tags / commits | ❌ |

## Reporting a Vulnerability

**Please do not open public issues for security problems.**

Report privately via GitHub's [private vulnerability reporting](https://github.com/W4-NERF/docker-comfyui/security/advisories/new) for this repository.

If GitHub's flow is unavailable, you can email the maintainer at the address on the [W4-NERF](https://github.com/W4-NERF) profile.

When you report, please include:

- A description of the issue and its impact
- Steps to reproduce, or a proof of concept
- The commit SHA you were testing against
- Any suggested fix, if you have one

You can expect:

- An acknowledgement within **7 days**
- A triage update within **30 days**
- Coordinated disclosure: a patch on `main` and a public advisory once a fix is available, with credit to you if you'd like

## Scope

**In scope** — issues in the files maintained by this repository:

- `Dockerfile`, `docker-entrypoint.sh`, `docker-compose.yml`
- `Makefile`, `scripts/*`
- The default `ComfyUI-Manager` `config.ini` seeded by the entrypoint
- The defaults in `.env.example` (network binding, privileges, etc.)

**Out of scope** — please report these to the appropriate upstream project:

- Vulnerabilities in **ComfyUI itself** → [comfyanonymous/ComfyUI](https://github.com/comfyanonymous/ComfyUI/security)
- Vulnerabilities in **ComfyUI-Manager** → [ltdrdata/ComfyUI-Manager](https://github.com/ltdrdata/ComfyUI-Manager)
- Vulnerabilities in **custom nodes** installed via Manager → the custom node's own repository
- Vulnerabilities in third-party Python packages → that package's project
- Issues that require an attacker who already has shell access to the host or container
- "ComfyUI-Manager can execute arbitrary code" — this is documented behavior, not a vulnerability. Treat the UI as a code-execution surface and bind it accordingly.

## Hardening Notes

This stack ships with conservative defaults but is **not a hardened appliance**:

- The UI binds to `127.0.0.1` by default — exposing it on a network (`BIND_ADDR=0.0.0.0`) without a reverse proxy + authentication is not supported.
- The container runs as a non-root user (`gosu`-dropped) with `no-new-privileges`, but it has GPU device passthrough and a writable bind mount over `custom_nodes/`. A malicious custom node can read your models, your outputs, and call the GPU.
- `ComfyUI-Manager.security_level = normal` allows installing arbitrary nodes from the UI. If you expose the UI, raise this first (see Manager docs for current level semantics).

Operational responsibility — your models, your custom nodes, your network exposure — is yours. See the [Disclaimer](./README.md#disclaimer).
