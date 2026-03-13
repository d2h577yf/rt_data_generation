FROM docker.io/nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# 【提速核心 1】针对 Ubuntu 24.04 (DEB822 格式) 的清华源替换，彻底解决 apt 卡死
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources && \
    sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    ca-certificates \
    git \
    wget \
    curl \
    build-essential \
    ninja-build \
    # --- 核心替换：用 libgl1 代替 libgl1-mesa-glx ---
    libgl1 \
    # -------------------------------------------
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    # 图形和渲染依赖 (Ubuntu 24.04 下这些名字依然有效)
    libglu1-mesa \
    libxi6 \
    libxrandr2 \
    libxinerama1 \
    libxcursor1 \
    # Python 及其开发头文件
    python3.12 \
    python3.12-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# 优先拷贝配置文件
COPY pyproject.toml uv.lock ./

ENV UV_PROJECT_ENVIRONMENT=/app/.venv
ENV UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple

# 【提速核心 3】只同步环境依赖，不安装当前项目。把这一步变成稳固的 Docker 缓存层
RUN UV_HTTP_TIMEOUT=300 UV_HTTP_RETRIES=5 uv sync --python 3.12 --no-install-project

ENV PATH="/app/.venv/bin:$PATH"

# 将项目自身安装进环境（因为前面依赖已经装好了，这一步会非常快）
RUN uv sync --python 3.12

RUN uv pip install jupyterlab
# 暴露 Jupyter Lab 端口
EXPOSE 8888


