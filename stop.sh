#!/bin/bash

echo "Parando os containers..."
docker stop apache-container mysql-container

echo "Removendo os containers..."
echo "docker rm apache-container mysql-container"

echo "Removendo o volume do MySQL, execute:"
echo "docker volume rm mysql_data"

echo "Processo concluído!"

