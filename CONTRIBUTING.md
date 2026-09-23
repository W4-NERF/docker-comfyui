# Contributing

This is a small, maintained-on-best-effort Docker wrapper (see [SECURITY.md](./SECURITY.md) for the support policy). Contributions are welcome, especially around the `Dockerfile`, `docker-entrypoint.sh`, `docker-compose.yml`, and `scripts/`.

## Before opening a PR

- Explain the "why," not just the "what" — what were you seeing, what should happen instead.
- Keep changes scoped. This repo intentionally stays small; prefer a focused fix over a broader refactor.
- If you touch `Dockerfile` or `docker-entrypoint.sh`, do a local build/run pass (`docker compose up --build`) before submitting — CI builds the image and lints with hadolint/shellcheck, but a real GPU/model run isn't part of CI.
- Update `README.md` and `.env.example` if you add or change a configuration variable.

## Reporting security issues

Please don't open a public issue — see [SECURITY.md](./SECURITY.md#reporting-a-vulnerability).

## Reporting bugs / requesting features

Use the issue templates; they ask for the environment details (driver, `CUDA_VARIANT`, logs) needed to reproduce.
