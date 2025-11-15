FROM node:alpine3.20

WORKDIR /app

COPY . .

# 增加对 SSHD 的支持，并配置公钥
RUN apk update && apk upgrade && \
    # 安装 openssh 和其他必需工具
    apk add --no-cache bash curl gcompat iproute2 coreutils openssl openssh && \
    
    # 1. 生成 SSH 主机密钥
    ssh-keygen -A && \
    
    # 2. 为 root 用户创建 .ssh 目录和 authorized_keys 文件
    mkdir -p /root/.ssh && \
    # 3. 写入用户提供的 SSH 公钥
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQC2PW7hbCLavixyb0Ela5MzCNH7ondCLEBOgIZTSMRIEZlLHejIRK9+o7Y2h3FktyBoy+LnbU1sEDrBkkmPl7MS1zvCq29IUaeUBiei2yRAkUJyjLCH9MGsTcgaEJD0yprD0/Bb3N8TWQKPZcL0bJJIY1aoULE6212ZuxJ0PdciPQ==" > /root/.ssh/authorized_keys && \
    
    # 设置正确的权限
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/authorized_keys && \
    
    # 确保 sshd 配置允许 root 登录
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    
    # 继续执行原有命令
    chmod +x index.js && \
    npm install

EXPOSE 8001/tcp
#EXPOSE 22/tcp # 暴露 SSH 服务的端口

ENV UUID=c274de0b-dd6d-4e63-0000-06b0ee67139e

# 注意：移除了 entrypoint.sh 的复制和 ENTRYPOINT 指令。

# 将 sshd 启动命令合并到 CMD：
# 使用 sh -c 运行一个子 shell，其中：
# 1. /usr/sbin/sshd &：将 SSHD 放入后台运行。
# 2. 接着执行原有的配置和 Node.js 启动命令。
CMD sh -c "/usr/sbin/sshd & printf 'nameserver 1.1.1.3\\nnameserver 2606:4700:4700::1003\\n' > /etc/resolv.conf && node index.js"
