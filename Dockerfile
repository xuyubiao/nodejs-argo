FROM node:alpine3.20

WORKDIR /app

COPY . .

# 增加对 SSHD 的支持
RUN apk update && apk upgrade && \
    # 安装 openssh 和其他必需工具
    apk add --no-cache bash curl gcompat iproute2 coreutils openssl openssh vim busybox-extras shadow && \  
    # 1. 生成 SSH 主机密钥
    ssh-keygen -A && \    
    # 2. 为 root 用户创建 .ssh 目录
    mkdir -p /root/.ssh && \    
    # 设置正确的权限
    chmod 700 /root/.ssh && \   
    # 确保 sshd 配置允许 root 登录
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && echo 'root:PassWd@987' | chpasswd  && \
    # 继续执行原有命令
    chmod +x index.js && \
    npm install

EXPOSE 8001/tcp
#EXPOSE 22/tcp # 暴露 SSH 服务的端口

ENV UUID=c274de0b-dd6d-4e63-0000-06b0ee67139e

CMD sh -c "/usr/sbin/sshd & printf 'nameserver 1.1.1.2\\nnameserver 2606:4700:4700::1002\\n' > /etc/resolv.conf && node index.js"
