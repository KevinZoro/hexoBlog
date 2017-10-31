FROM node:8.2

RUN npm install -g hexo --registry=https://registry.npm.taobao.org

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app

EXPOSE 4000

CMD ['hexo', 'server']