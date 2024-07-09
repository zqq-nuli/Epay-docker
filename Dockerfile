# 使用官方的PHP 7.4镜像
FROM php:7.4-fpm

# 安装依赖项
RUN apt-get update && apt-get install -y \
    pkg-config \
    libcurl4-openssl-dev \
    default-mysql-client

# 创建日志目录并设置权限
RUN mkdir -p /www/wwwlogs \
    && touch /www/wwwlogs/localhost.log \
    && touch /www/wwwlogs/localhost.error.log \
    && chmod -R 755 /www/wwwlogs

# 安装PDO_MYSQL和CURL扩展
RUN docker-php-ext-install pdo_mysql curl

# 将当前目录下的代码复制到容器的/var/www/html目录
COPY ./website/ /var/www/html/