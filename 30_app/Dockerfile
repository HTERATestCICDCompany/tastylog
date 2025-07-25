FROM node:16-alpine

# bcryptのビルドに必要な依存関係をインストール
RUN apk add --no-cache python3 make g++

COPY . /home/node/webapp

RUN cd /home/node/webapp; \
    mv docker-entrypoint.sh /usr/local/bin; \
    chmod +x /usr/local/bin/docker-entrypoint.sh; \
    npm install;

# MySQL環境変数はECSタスク定義のSSMパラメータから設定される

EXPOSE 3000

WORKDIR /home/node/webapp
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "npm", "start" ]