FROM nvcr.io/nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    ca-certificates \
    git \
    wget \
    curl \
    # OpenCV 依赖
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    # 图形和渲染依赖
    libglu1-mesa \
    libxi6 \
    libxrandr2 \
    libxinerama1 \
    libxcursor1 \
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

# 创建非 root 用户以兼容 podman
RUN useradd -m -u 1000 -s /bin/bash appuser && \
    chown -R appuser:appuser /app

# 复制项目文件
COPY --chown=appuser:appuser . .

USER appuser

# 暴露 Jupyter Lab 端口
EXPOSE 8888

# 配置 Jupyter Lab (开发模式，禁用 token)
# 生产环境建议设置密码或使用 token
CMD ["jupyter", "lab", \
     "--ip=0.0.0.0", \
     "--port=8888", \
     "--no-browser", \
     "--ServerApp.token=''", \
     "--ServerApp.password=''", \
     "--ServerApp.allow_root=True"]
