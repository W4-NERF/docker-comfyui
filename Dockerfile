# Stage 1: base
FROM python:3.11-slim AS base

ARG COMFYUI_VERSION=v0.24.1
ENV COMFYUI_VERSION=${COMFYUI_VERSION}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    gosu \
    libgl1 \
    libglib2.0-0 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

ARG UID=1000
ARG GID=1000
ARG CUDA_VARIANT=cu128

RUN groupadd -g "${GID}" comfyui && \
    useradd -m -u "${UID}" -g comfyui -s /bin/bash comfyui

WORKDIR /comfyui

# Shallow-clone the tag, then create a local master branch so Manager's
# "checkout master" for updates doesn't fail (shallow clones lack branches).
# Install torch *before* requirements.txt so the CUDA-specific index is used
# for the torch wheel; requirements.txt then resolves remaining deps from PyPI.
RUN git init && \
    git remote add origin https://github.com/comfyanonymous/ComfyUI.git && \
    git fetch --depth 1 origin tag "${COMFYUI_VERSION}" && \
    git checkout -b master tags/"${COMFYUI_VERSION}" && \
    pip install --no-cache-dir --root-user-action=ignore --disable-pip-version-check \
        torch torchvision torchaudio --index-url https://download.pytorch.org/whl/${CUDA_VARIANT} && \
    pip install --no-cache-dir --root-user-action=ignore --disable-pip-version-check -r requirements.txt && \
    pip install --no-cache-dir --root-user-action=ignore --disable-pip-version-check GitPython openai-agents && \
    chown -R comfyui:comfyui /comfyui /usr/local/lib/python3.11/site-packages /usr/local/bin

COPY --chown=root:root docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8188

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl -f http://localhost:8188/system_stats || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
