# 彩虹易支付-docker 版

> 网上全是彩虹的宝塔版搭建教程，其他的`docker`容器我看还有收钱的，索性就自己做一个吧。  


## 本地测试教程

### 配置环境

1. 安装 `Docker` 环境 Windows 安装 [Docker Desktop](https://www.docker.com/products/docker-desktop/)  
  docker 环境在此不过多赘述，请看别的安装教程

### 本地测试

PS：本项目不提供易支付源码，请自行寻找/购买正版

1. 环境配置完成后，解压易支付源码，放入 `website` 目录下
2. 在项目根目录下，执行执行下方命令运行容器

##### 启动容器
```sh
    docker-compose up --build
```

##### 停止/删除容器
```sh
    docker-compose down
```

 1. 访问本机测试地址 `http://localhost:1443` ，由于开启了 强制 `https` 所以可能会跳转到 `https://localhost` 手动输入端口即可
 2. 点击下一步后，输入 `Mysql` 信息，需要将数据库地址 改为 `db` ，而不是原来的  `localhost`
 3. 数据库账号密码等信息从 `docker-compose.yml` - `db` - `environment` 中寻找 即可正常安装


## 线上部署

> 本地测试没问题后  
> 1. ~~修改 `ssl` 文件夹下的证书替换为你要解析的域名的证书~~
> 2. 修改 `nginx.conf` 文件中的域名将所有的 `localhost` 替换为你的域名  
> 3. ~~将 `nginx.conf` 文件的第 `nginx.crt` 与 `nginx.key` 替换为你的证书文件名~~
> 4. 删除 `.git` 目录 与 `README.md` 文件  
> 5. 将所有代码上传至服务器，运行下方命令启动容器

### 打包容器
```sh
    docker-compose build
```
### 启动容器
```sh
    docker-compose up -d
```
### 停止容器
```sh
    docker-compose stop
```
### 删除容器(有修改后要删除，然后再打包)
```sh
    docker-compose down
```



## 自定义配置

> 主要是修改 `docker-compose.yml` 文件，下面是一些字段解释   
> `.env.example` 中的 `COMPOSE_PROJECT_NAME` 为 `docker` 容器名，如有特殊请自行修改  
> `nginx` 的修改，请自行研究


```yml
version: '3.8'

services:
  nginx:
    image: nginx:latest
    ports: # 如果外部有端口冲突 请修改此项
      - "1080:80"  # 将 容器内的 80 端口 映射到外部 1080
    user: root
    volumes:
      - ./website:/var/www/html
      - ./nginx.conf:/etc/nginx/conf.d/pay.conf
      - ./ssl:/etc/nginx/ssl
      - ./fastcgi-php.conf:/etc/nginx/snippets/fastcgi-php.conf
      - ./www/wwwlogs:/www/wwwlogs
    depends_on:
      - php

  php:
    build: .
    user: root
    volumes:
      - ./website:/var/www/html

  db:
    image: mysql:5.7 # mysql 版本
    environment: # mysql 信息
      MYSQL_ROOT_PASSWORD: root_password # root 密码
      MYSQL_DATABASE: my_database # 数据库名
      MYSQL_USER: user # 用户名
      MYSQL_PASSWORD: user_password # 用户密码
    ports:
      - "3306:3306"
```


## 项目结构
```sh
├─website
    └─index.php
    └─****//易支付源代码
└─www
    └─wwwlogs
└─.env.example
└─docker-compose.yml
└─Dockerfile
└─fastcgi-php.conf
└─nginx.conf
└─REDAME.md
```


## 更新 2024-07-12

1. 去掉https配置
2. 修复文件目录无写入权限问题

PS：现在容器内只映射80端口 外部配置域名与证书
