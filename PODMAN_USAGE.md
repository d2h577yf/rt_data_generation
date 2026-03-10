# RT Data Generation - Podman 使用指南

## 准备工作

确保已安装：
- Podman
- NVIDIA Container Toolkit (用于 GPU 支持)

### 配置 Podman GPU 支持

```bash
# 安装 nvidia-container-toolkit
sudo apt-get install -y nvidia-container-toolkit

# 配置 podman 使用 CDI (Container Device Interface)
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
```

## 快速开始

### 1. 构建镜像

```bash
./build.sh
```

或手动执行：
```bash
podman build -t rt-data-gen:latest -f Containerfile .
```

### 2. 运行容器

```bash
./run.sh
```

或手动执行：
```bash
podman run --rm -it \
  --device nvidia.com/gpu=all \
  --security-opt=label=disable \
  -p 8888:8888 \
  -v "$(pwd)":/app:Z \
  rt-data-gen:latest
```

### 3. 访问 Jupyter Lab

容器启动后，在浏览器中打开：
```
http://localhost:8888
```

## 参数说明

- `--rm`: 容器停止后自动删除
- `-it`: 交互式终端
- `--device nvidia.com/gpu=all`: 使用所有 GPU
- `--security-opt=label=disable`: 禁用 SELinux 标签（如果遇到权限问题）
- `-p 8888:8888`: 端口映射
- `-v "$(pwd)":/app:Z`: 挂载当前目录（`:Z` 用于 SELinux 重新标记）

## 常见问题

### GPU 不可用
检查 CDI 设备：
```bash
podman run --rm rt-data-gen:latest ls /dev
```

### 权限问题
如果遇到权限错误，尝试：
```bash
podman unshare chown -R 1000:1000 .
```

### 保存数据集
数据集默认保存在 `./dataset/` 目录，由于使用了卷挂载（`-v`），数据会持久化到宿主机。

## 生产环境建议

编辑 Containerfile，启用 Jupyter 安全设置：
```bash
# 生成密码哈希
jupyter lab password
```

然后在 Containerfile 的 CMD 中替换：
```dockerfile
CMD ["jupyter", "lab", \
     "--ip=0.0.0.0", \
     "--port=8888", \
     "--no-browser", \
     "--ServerApp.password='your-hashed-password'"]
```
