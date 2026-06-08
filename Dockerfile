# Stage 1: base
FROM python:3.11-slim AS base

ARG COMFYUI_VERSION
ENV COMFYUI_VERSION=${COMFYUI_VERSION}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    sudo \
    libgl1 \
    libglib2.0-0t64 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

ARG UID=1000
ARG GID=1000

RUN groupadd -g "${GID}" comfyui && \
    useradd -m -u "${UID}" -g comfyui -s /bin/bash comfyui

WORKDIR /comfyui

# Shallow-clone the tag, then create a local master branch so Manager's
# "checkout master" for updates doesn't fail (shallow clones lack branches).
RUN git init && \
    git remote add origin https://github.com/comfyanonymous/ComfyUI.git && \
    git fetch --depth 1 origin tag "${COMFYUI_VERSION}" && \
    git checkout -b master tags/"${COMFYUI_VERSION}" && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir \
        torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124 && \
    pip install --no-cache-dir GitPython openai-agents && \
    chown -R comfyui:comfyui /comfyui && \
    chown -R comfyui:comfyui /usr/local

COPY --chown=root:root docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8188

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl -f http://localhost:8188/ || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
