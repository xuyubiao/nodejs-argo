# 使用 Ubuntu 24.04 作为基础镜像
FROM ubuntu:24.04

# 设置环境变量，防止 apt 安装过程中出现交互式弹窗
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# 拷贝项目文件
COPY . .

# 更新系统并安装所需依赖
RUN apt-get update && apt-get upgrade -y && \
    # 安装 Node.js 20.x (Ubuntu 24.04 官方仓库默认版本) 和 SSH 相关工具
    # 注意：Ubuntu 下不再需要 gcompat，glibc 是原生的
    apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    curl \
    openssh-server \
    vim \
    iproute2 \
    ca-certificates \
    openssl \
    bash \
    sudo && \
    # 1. 配置 SSH 服务
    mkdir -p /run/sshd && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh && \
    # 2. 修改 SSH 配置允许 root 登录
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    # 3. 设置 root 密码
    echo 'root:PassWd@987' | chpasswd && \
    # 4. 这里的 index.js 如果是二进制执行文件，需要执行权限
    chmod +x index.js && \
    # 安装 npm 依赖
    npm install && \
    # 清理缓存以缩小镜像体积
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 暴露端口
EXPOSE 8001/tcp
# EXPOSE 22/tcp

ENV UUID=c274de0b-dd6d-4e63-0000-06b0ee67139e

# 启动命令
# 注意：Ubuntu 的 sshd 路径通常在 /usr/sbin/sshd
CMD bash -c "/usr/sbin/sshd && printf 'nameserver 1.1.1.2\nnameserver 2606:4700:4700::1002\n' > /etc/resolv.conf && node index.js"
