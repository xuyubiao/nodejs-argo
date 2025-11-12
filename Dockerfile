FROM node:alpine3.20

WORKDIR /app

COPY . .

EXPOSE 8001/tcp

ENV UUID=c274de0b-dd6d-4e63-a241-06b0ee67139e

RUN apk update && apk upgrade && \
    apk add --no-cache bash curl gcompat iproute2 coreutils openssl && \
    chmod +x index.js && \
    npm install

# 使用 shell form 启动，以支持重定向
CMD sh -c "printf 'nameserver 1.1.1.3\nnameserver 2606:4700:4700::1003\n' > /etc/resolv.conf && node index.js"
