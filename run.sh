#!/bin/bash
# 使用 podman 运行容器（带 GPU 支持）

podman run --rm -it \
    --device nvidia.com/gpu=3 \
    --userns=keep-id \
    -p 8888:8888 \
    -v "$(pwd)":/app:Z \
    rt-data-gen:latest
