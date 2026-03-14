#!/bin/bash
# 使用 podman 构建镜像
export TMPDIR=/home/DataDisk/plzheng/podman_storage/tmp
podman build --network=host -t rt-data-gen:latest -f Containerfile .
