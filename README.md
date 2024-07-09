# 彩虹易支付-docker 版

> 网上全是彩虹的宝塔版搭建教程，官方除了收钱和开发插件收钱，似乎其他的也不怎么管，其他的`docker`容器我看还有收钱的，索性就自己做一个吧。  


## 本地测试教程

### 配置环境

1. 安装 `Docker` 环境 Windows 安装 [Docker Desktop](https://www.docker.com/products/docker-desktop/)  
  docker 环境在此不过多赘述，请看别的安装教程

2. 安装 `Openssl` 用于本地测试生成证书  
[Openssl for Windows](http://slproweb.com/products/Win32OpenSSL.html) 下载 `Light` 版本就行  
然后无脑下一步安装，记一下安装位置，方便等下设置环境变量  
找到【系统属性】-【环境变量】-【系统变量】中 Path 变量后点击编辑  
设置 `openssl` 的环境变量（安装 openssl 路径的 bin 目录）  
Windows 打开 `shell` 输出 `openssl version` 不报错且正常输出 `openssl` 版本即说明安装成功。
3. 生成本地测试自签证书
打开 `shell` 进入到 `ssl` 目录 执行以下命令  
```sh
    openssl req -new -x509 -nodes -days 365 -config openssl.cnf -keyout nginx.key -out nginx.crt
```
然后会在本地看到两个文件 `nginx.key` 与 `nginx.crt`  
有特殊要求的可以修改 `openssl.cnf` 文件

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

 1. 访问本机测试地址 `http://localhost:1443` ，由于开启了 强制 `https` 所以可能会跳转到 `https://localhost` 手动输入，手动输入端口即可
 2. 点击下一步后，输入 `Mysql` 信息，需要将数据库地址 改为 `db` ，而不是原来的  `localhost`
 3. 数据库账号密码等信息从 `docker-compose.yml` - `db` - `environment` 中寻找 即可正常安装


## 线上部署

> 本地测试没问题后  
> 1. 修改 `ssl` 文件夹下的证书替换为你要解析的域名的证书  
> 2. 修改 `nginx.conf` 文件中的域名将所有的 `localhost` 替换为你的域名  
> 3. 将 `nginx.conf` 文件的第 `nginx.crt` 与 `nginx.key` 替换为你的证书文件名  
> 4. 删除 `.git` 目录 与 `README.md` 文件  
> 5. 将所有代码上传至服务器，运行下方命令启动容器

```sh
    docker-compose up -d
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
      - "1443:443" # 将 容器内的 443 端口 映射到外部 1443 
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

├─ssl
    └─nginx.crt
    └─nginx.key
    └─openssl.conf
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
