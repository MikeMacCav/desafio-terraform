FROM mysql:8.0

# Define as variáveis de ambiente do MySQL
ENV MYSQL_ROOT_PASSWORD=metroid
ENV MYSQL_DATABASE=sre_desafio
ENV MYSQL_USER=admin
ENV MYSQL_PASSWORD=metroid

# Copia o script de inicialização
COPY init.sql /docker-entrypoint-initdb.d/

# Expõe a porta do MySQL
EXPOSE 3306
