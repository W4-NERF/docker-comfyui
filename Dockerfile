FROM python:3.14-slim

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

# Full pip specs for the torch stack. Left unpinned by default (always the
# latest build compatible with CUDA_VARIANT); override at build time — e.g.
# --build-arg TORCH_PACKAGES="torch==2.8.0 torchvision==0.23.0 torchaudio==2.8.0"
# — to stop a `docker compose build --no-cache` from silently jumping to a
# newer torch that the pinned COMFYUI_VERSION doesn't support yet.
ARG TORCH_PACKAGES="torch torchvision torchaudio"
# Same idea for ComfyUI-Copilot's dependency, e.g. --build-arg OPENAI_AGENTS_PACKAGE="openai-agents==0.x.y".
# Exported as ENV so the entrypoint's runtime reinstall (survives container
# recreation) honors the same pin instead of drifting back to latest.
ARG OPENAI_AGENTS_PACKAGE="openai-agents"
ENV OPENAI_AGENTS_PACKAGE=${OPENAI_AGENTS_PACKAGE}

RUN groupadd -g "${GID}" comfyui && \
    useradd -l -m -u "${UID}" -g comfyui -s /bin/bash comfyui

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
        ${TORCH_PACKAGES} --index-url https://download.pytorch.org/whl/${CUDA_VARIANT} && \
    pip install --no-cache-dir --root-user-action=ignore --disable-pip-version-check -r requirements.txt && \
    pip install --no-cache-dir --root-user-action=ignore --disable-pip-version-check GitPython ${OPENAI_AGENTS_PACKAGE} && \
    chown -R comfyui:comfyui /comfyui /usr/local/lib/python3.11/site-packages /usr/local/bin

COPY --chown=root:root docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8188

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl -f http://localhost:8188/system_stats || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
