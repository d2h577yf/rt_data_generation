FROM nvcr.io/nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    ca-certificates \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY pyproject.toml uv.lock ./

ENV UV_PROJECT_ENVIRONMENT=/app/.venv
RUN uv sync --frozen --python 3.12

ENV PATH="/app/.venv/bin:$PATH"

CMD ["python", "-c", "import tensorflow as tf; print('TensorFlow version:', tf.__version__); print('Num GPUs Available:', len(tf.config.list_physical_devices('GPU')))"]
