FROM php:8.1-apache

# Instala a extensão mysqli
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

# Copia os arquivos do projeto
COPY . /var/www/html/

# Expõe a porta do Apache
EXPOSE 80

