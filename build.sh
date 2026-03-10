#!/bin/bash
# 使用 podman 构建镜像

podman build -t rt-data-gen:latest -f Containerfile .
