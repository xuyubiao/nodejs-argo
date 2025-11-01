FROM node:alpine3.20

WORKDIR /tmp

COPY . .

EXPOSE 8001/tcp

ENV UUID=c274de0b-dd6d-4e63-a241-06b0ee67139e

RUN apk update && apk upgrade &&\
    apk add --no-cache openssl curl gcompat iproute2 coreutils &&\
    apk add --no-cache bash &&\
    chmod +x index.js &&\
    npm install

CMD ["node", "index.js"]
