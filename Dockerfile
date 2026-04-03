# syntax=docker/dockerfile:1
# Revelo / CI-style image: from-source install (non-editable). Local dev path is README.md.
FROM python:3.11-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends git build-essential \
    && rm -rf /var/lib/apt/lists/*

# Isolated env (avoids Debian PEP 668 / system pip issues)
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Pinned installer; PyTorch pins satisfy core/src/autogluon/core/_setup_utils.py (torch>=2.6,<2.10).
RUN pip install --no-cache-dir "uv==0.6.14"

WORKDIR /workspace
COPY . .
RUN chmod +x full_install.sh \
    && python -m uv pip install \
        "torch==2.6.0" "torchvision==0.21.0" \
        --extra-index-url https://download.pytorch.org/whl/cpu \
    && ./full_install.sh --non-editable
