#!/bin/bash

# 安装 Docker 函数
install_docker() {
    # CentOS 安装 Docker
    if [ -f /etc/centos-release ]; then
        sudo yum install -y yum-utils device-mapper-persistent-data lvm2
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io
        sudo systemctl start docker
        sudo systemctl enable docker
    # Ubuntu 安装 Docker
    elif [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
        sudo apt-get update
        sudo apt-get install -y docker.io
        sudo systemctl start docker
        sudo systemctl enable docker
    else
        echo "Unsupported OS"
        exit 1
    fi
}

# 安装 Docker
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing..."
    install_docker
else
    echo "Docker already installed."
fi

# 检查容器是否已经存在
if [ "$(docker ps -q -f name=traffmonetizer)" ]; then
    echo "Container traffmonetizer already exists."
    exit 0
fi

# 检查系统类型
if [[ "$(uname -m)" == "x86_64" ]]; then
    # x86_64 机器
    DOCKER_IMAGE="traffmonetizer/cli_v2:latest"
elif [[ "$(uname -m)" == "aarch64" ]]; then
    # ARM 机器
    DOCKER_IMAGE="traffmonetizer/cli_v2:arm64v8"
else
    echo "Unsupported architecture"
    exit 1
fi

# 拉取 Docker 镜像
docker pull $DOCKER_IMAGE

# 运行 Docker 容器
docker run -d --name traffmonetizer $DOCKER_IMAGE start accept --token ZG7q6f7uBEIYAWbZ3KMvnH7KJcl1K6mgqzVC+O4g7L8=
