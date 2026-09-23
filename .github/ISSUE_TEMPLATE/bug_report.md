---
name: Bug report
about: Something in the container/build/entrypoint is broken
title: ''
labels: ''
assignees: ''

---

**Describe the bug**
A clear and concise description of what's wrong.

**To Reproduce**
Steps to reproduce, e.g.:
1. Set these values in `.env`: ...
2. Run `make up` (or `docker compose up --build`)
3. See error

**Expected behavior**
What you expected to happen instead.

**Environment**
 - Host OS: [e.g. Ubuntu 22.04]
 - GPU / driver version: [e.g. RTX 4090, driver 575.x — `nvidia-smi`]
 - Docker version: [`docker --version`]
 - `docker compose` version: [`docker compose version`]
 - Relevant `.env` values: `COMFYUI_VERSION`, `CUDA_VARIANT`, `COMFYUI_EXTRA_ARGS` (omit anything sensitive)

**Logs**
Output of `docker compose logs comfyui` (or `make logs`) around the failure. Please paste as text, not a screenshot.

**Additional context**
Anything else that might be relevant (custom nodes installed, model sizes, etc.).
