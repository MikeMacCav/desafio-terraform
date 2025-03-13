#!/bin/bash

# Inicia o MySQL
docker run -d --name mysql-container \
  --restart unless-stopped \
  -e MYSQL_ROOT_PASSWORD=metroid \
  -e MYSQL_DATABASE=sre_desafio \
  -e MYSQL_USER=admin \
  -e MYSQL_PASSWORD=metroid \
  -p 3306:3306 \
  -v mysql_data:/var/lib/mysql \
  mysql:8.0

# Aguarda o MySQL iniciar
echo "Aguardando MySQL iniciar..."
until docker exec mysql-container mysqladmin ping -h "localhost" --silent; do
    sleep 2
done
echo "MySQL pronto!"

# Inicia o Apache/PHP
docker run -d --name apache-container \
  --restart unless-stopped \
  --link mysql-container:mysql \
  -p 8080:80 \
  -v $(pwd)/apache:/var/www/html \
  php:8.1-apache
