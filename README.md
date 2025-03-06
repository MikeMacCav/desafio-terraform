
# 🚀 Desafio SRE/DevOps - Configuração de Infraestrutura com Terraform e Deploy de Containers
Este repositório contém a configuração da infraestrutura utilizando Terraform, além da configuração de um servidor AWS EC2 para deploy de containers Docker.

# 📌 Passo a Passo - O que foi feito até agora
# 1️⃣ Configuração Inicial do Ambiente
Instalei o Terraform e configurei o ambiente local.
Criei uma chave SSH para acessar a instância EC2:
sh
Copiar
Editar
ssh-keygen -t rsa -b 4096 -m PEM -f F:/terraform/keys/terraform-key -N ""
Importei a chave pública para a AWS:
sh
Copiar
Editar
aws ec2 import-key-pair --key-name "terraform-key" --public-key-material fileb://F:/terraform/keys/terraform-key.pub
# 2️⃣ Criação da Infraestrutura na AWS
Criei um arquivo main.tf com:

Configuração do provider AWS.
Definição de um grupo de segurança.
Criação de uma instância EC2 com Ubuntu 20.04.

Arquivo Main(Configuração inicial):

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-011e48799a29115e9" # AMI do Ubuntu 20.04
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_key.key_name
  security_groups = [aws_security_group.instance_sg.name]

  tags = {
    Name = "DesafioTerraform-EC2"
  }
}

# Apliquei a configuração:

sh
Copiar
Editar
terraform init
terraform plan
terraform apply
# 3️⃣ Uso de Instância Existente ao invés de Criar uma Nova
Criei um data source no Terraform para reutilizar uma instância EC2 existente:
hcl
Copiar
Editar
data "aws_instance" "app_server" {
  filter {
    name   = "tag:Name"
    values = ["DesafioTerraform-EC2"]
  }
}
# Tentei importar a instância existente:
sh
Copiar
Editar
terraform import aws_instance.app_server i-0bb54181aed6221ec
⚠️ Erro encontrado: "resource address does not exist in the configuration".
🔹 Correção: Criei a configuração do recurso antes de importar.
# 4️⃣ Provisionamento e Deploy de Containers com Docker
# Criei um provisionador remoto (remote-exec) para instalar o Docker e executar os containers:
hcl
Copiar
Editar
resource "null_resource" "deploy_containers" {
  depends_on = [data.aws_instance.app_server]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("F:/terraform/keys/terraform-key")
      host        = data.aws_instance.app_server.public_ip
    }

    inline = [
      "sudo apt update -y",
      "sudo apt install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu",
      "cd desafio-sre-devops",
      "sudo docker build -t apache-container -f apache/Dockerfile .",
      "sudo docker build -t container-mysql -f mysql/Dockerfile .",
      "sudo docker run -d --name apache-container -p 80:80 apache-container",
      "sudo docker run -d --name container-mysql -p 3306:3306 container-mysql"
    ]
  }
}
# Rodei terraform apply, mas encontrei um erro de SSH:
vbnet
Copiar
Editar
Error: remote-exec provisioner error
Failed to parse ssh private key: ssh: this private key is passphrase protected
⚠️ Problema: A chave privada está protegida por passphrase e o Terraform não consegue usá-la diretamente.
🔹 Solução: Precisei adicionar a chave ao ssh-agent ou criar uma nova sem passphrase.
# 5️⃣ Correção do Erro de Chave SSH
Para usar a chave protegida no Windows (Git Bash) ou Linux/macOS:
sh
Copiar
Editar
eval $(ssh-agent -s)
ssh-add F:/terraform/keys/terraform-key
Se precisar de uma nova chave sem passphrase, gerar e importar novamente:
sh
Copiar
Editar
ssh-keygen -t rsa -b 4096 -m PEM -f F:/terraform/keys/terraform-key -N ""
aws ec2 import-key-pair --key-name "terraform-key" --public-key-material fileb://F:/terraform/keys/terraform-key.pub
# 🚀 Próximos Passos
# ✅ Resolver o problema da chave SSH.
# ✅ Testar novamente o deploy com terraform apply.
# ⏳ Configurar volumes persistentes no MySQL.
# ⏳ Melhorar a organização dos Dockerfiles e adicionar um README.md no repositório do desafio.
# 📌 Status: Em andamento
# 📌 Tecnologias utilizadas:
# ✅ Terraform - Automação da infraestrutura
# ✅ AWS EC2 - Instância do servidor
# ✅ Docker - Deploy de containers


# 📌 Atualização: 06/03/2025 - Deploy do container realizado com sucesso.
# Print do Deploy:
![image](https://github.com/user-attachments/assets/736879f4-b230-4eb9-ac6a-b61738d00257)

# Relatório Completo do Deploy
- F:\terraform\desafio-terraform>terraform apply -auto-approve
data.aws_instance.app_server: Reading...
aws_key_pair.ssh_key: Refreshing state... [id=terraform-key]
aws_security_group.instance_sg: Refreshing state... [id=sg-0c98dd5ff33ab0e6e]
data.aws_instance.app_server: Read complete after 3s [id=i-0bb54181aed6221ec]
null_resource.deploy_containers: Refreshing state... [id=7521652978019103102]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # null_resource.deploy_containers is tainted, so must be replaced
-/+ resource "null_resource" "deploy_containers" {
      ~ id = "7521652978019103102" -> (known after apply)
    }

Plan: 1 to add, 0 to change, 1 to destroy.
null_resource.deploy_containers: Destroying... [id=7521652978019103102]
null_resource.deploy_containers: Destruction complete after 0s
null_resource.deploy_containers: Creating...
null_resource.deploy_containers: Provisioning with 'remote-exec'...
null_resource.deploy_containers (remote-exec): Connecting to remote host via SSH...
null_resource.deploy_containers (remote-exec):   Host: 54.175.245.152
null_resource.deploy_containers (remote-exec):   User: ubuntu
null_resource.deploy_containers (remote-exec):   Password: false
null_resource.deploy_containers (remote-exec):   Private key: true
null_resource.deploy_containers (remote-exec):   Certificate: false
null_resource.deploy_containers (remote-exec):   SSH Agent: false
null_resource.deploy_containers (remote-exec):   Checking Host Key: false
null_resource.deploy_containers (remote-exec):   Target Platform: unix
null_resource.deploy_containers (remote-exec): Connected!
null_resource.deploy_containers (remote-exec):
null_resource.deploy_containers (remote-exec): 0% [Working]
null_resource.deploy_containers (remote-exec): Hit:1 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal InRelease
null_resource.deploy_containers (remote-exec):
null_resource.deploy_containers (remote-exec): 0% [Connecting to security.ubuntu.com (
null_resource.deploy_containers (remote-exec): Hit:2 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal-updates InRelease
null_resource.deploy_containers (remote-exec): Hit:3 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal-backports InRelease
null_resource.deploy_containers (remote-exec):
null_resource.deploy_containers (remote-exec): 0% [Connecting to security.ubuntu.com (
null_resource.deploy_containers (remote-exec): Hit:4 http://security.ubuntu.com/ubuntu focal-security InRelease
null_resource.deploy_containers (remote-exec):
null_resource.deploy_containers (remote-exec): 0% [Working]
null_resource.deploy_containers (remote-exec): 0% [Working]
null_resource.deploy_containers (remote-exec):
null_resource.deploy_containers (remote-exec): 0% [Working]
null_resource.deploy_containers (remote-exec):
null_resource.deploy_containers (remote-exec): 0% [Working]
null_resource.deploy_containers (remote-exec): 20% [Working]
null_resource.deploy_containers (remote-exec): Reading package lists... 0%
null_resource.deploy_containers (remote-exec): Reading package lists... 0%
null_resource.deploy_containers (remote-exec): Reading package lists... 0%
null_resource.deploy_containers (remote-exec): Reading package lists... 2%
null_resource.deploy_containers (remote-exec): Reading package lists... 2%
null_resource.deploy_containers (remote-exec): Reading package lists... 3%
null_resource.deploy_containers (remote-exec): Reading package lists... 3%
null_resource.deploy_containers (remote-exec): Reading package lists... 3%
null_resource.deploy_containers (remote-exec): Reading package lists... 3%
null_resource.deploy_containers (remote-exec): Reading package lists... 3%
null_resource.deploy_containers (remote-exec): Reading package lists... 3%
null_resource.deploy_containers (remote-exec): Reading package lists... 24%
null_resource.deploy_containers (remote-exec): Reading package lists... 24%
null_resource.deploy_containers (remote-exec): Reading package lists... 25%
null_resource.deploy_containers (remote-exec): Reading package lists... 36%
null_resource.deploy_containers (remote-exec): Reading package lists... 36%
null_resource.deploy_containers (remote-exec): Reading package lists... 36%
null_resource.deploy_containers (remote-exec): Reading package lists... 36%
null_resource.deploy_containers (remote-exec): Reading package lists... 36%
null_resource.deploy_containers (remote-exec): Reading package lists... 36%
null_resource.deploy_containers (remote-exec): Reading package lists... 45%
null_resource.deploy_containers (remote-exec): Reading package lists... 45%
null_resource.deploy_containers (remote-exec): Reading package lists... 51%
null_resource.deploy_containers (remote-exec): Reading package lists... 51%
null_resource.deploy_containers (remote-exec): Reading package lists... 58%
null_resource.deploy_containers (remote-exec): Reading package lists... 61%
null_resource.deploy_containers (remote-exec): Reading package lists... 61%
null_resource.deploy_containers (remote-exec): Reading package lists... 65%
null_resource.deploy_containers (remote-exec): Reading package lists... 65%
null_resource.deploy_containers (remote-exec): Reading package lists... 68%
null_resource.deploy_containers (remote-exec): Reading package lists... 68%
null_resource.deploy_containers (remote-exec): Reading package lists... 69%
null_resource.deploy_containers (remote-exec): Reading package lists... 69%
null_resource.deploy_containers (remote-exec): Reading package lists... 69%
null_resource.deploy_containers (remote-exec): Reading package lists... 69%
null_resource.deploy_containers (remote-exec): Reading package lists... 69%
null_resource.deploy_containers (remote-exec): Reading package lists... 69%
null_resource.deploy_containers (remote-exec): Reading package lists... 69%
null_resource.deploy_containers (remote-exec): Reading package lists... 69%
null_resource.deploy_containers (remote-exec): Reading package lists... 69%
null_resource.deploy_containers (remote-exec): Reading package lists... 69%
null_resource.deploy_containers (remote-exec): Reading package lists... 69%
null_resource.deploy_containers (remote-exec): Reading package lists... 69%
null_resource.deploy_containers (remote-exec): Reading package lists... 69%
null_resource.deploy_containers (remote-exec): Reading package lists... 69%
null_resource.deploy_containers (remote-exec): Reading package lists... 77%
null_resource.deploy_containers (remote-exec): Reading package lists... 77%
null_resource.deploy_containers (remote-exec): Reading package lists... 83%
null_resource.deploy_containers (remote-exec): Reading package lists... 83%
null_resource.deploy_containers (remote-exec): Reading package lists... 92%
null_resource.deploy_containers (remote-exec): Reading package lists... 92%
null_resource.deploy_containers (remote-exec): Reading package lists... 95%
null_resource.deploy_containers (remote-exec): Reading package lists... 96%
null_resource.deploy_containers (remote-exec): Reading package lists... 96%
null_resource.deploy_containers (remote-exec): Reading package lists... 98%
null_resource.deploy_containers (remote-exec): Reading package lists... 98%
null_resource.deploy_containers (remote-exec): Reading package lists... 99%
null_resource.deploy_containers (remote-exec): Reading package lists... 99%
null_resource.deploy_containers (remote-exec): Reading package lists... 99%
null_resource.deploy_containers (remote-exec): Reading package lists... 99%
null_resource.deploy_containers (remote-exec): Reading package lists... 99%
null_resource.deploy_containers (remote-exec): Reading package lists... 99%
null_resource.deploy_containers (remote-exec): Reading package lists... Done
null_resource.deploy_containers (remote-exec): Building dependency tree... 0%
null_resource.deploy_containers (remote-exec): Building dependency tree... 0%
null_resource.deploy_containers (remote-exec): Building dependency tree... 0%
null_resource.deploy_containers (remote-exec): Building dependency tree... 50%
null_resource.deploy_containers (remote-exec): Building dependency tree... 50%
null_resource.deploy_containers (remote-exec): Building dependency tree
null_resource.deploy_containers (remote-exec): Reading state information... 0%
null_resource.deploy_containers (remote-exec): Reading state information... 0%
null_resource.deploy_containers (remote-exec): Reading state information... Done
null_resource.deploy_containers (remote-exec): 5 packages can be upgraded. Run 'apt list --upgradable' to see them.
null_resource.deploy_containers (remote-exec): Reading package lists... 0%
null_resource.deploy_containers (remote-exec): Reading package lists... 100%
null_resource.deploy_containers (remote-exec): Reading package lists... Done
null_resource.deploy_containers (remote-exec): Building dependency tree... 0%
null_resource.deploy_containers (remote-exec): Building dependency tree... 0%
null_resource.deploy_containers (remote-exec): Building dependency tree... 50%
null_resource.deploy_containers (remote-exec): Building dependency tree... 50%
null_resource.deploy_containers (remote-exec): Building dependency tree
null_resource.deploy_containers (remote-exec): Reading state information... 0%
null_resource.deploy_containers (remote-exec): Reading state information... 0%
null_resource.deploy_containers (remote-exec): Reading state information... Done
null_resource.deploy_containers (remote-exec): docker.io is already the newest version (26.1.3-0ubuntu1~20.04.1).
null_resource.deploy_containers (remote-exec): 0 upgraded, 0 newly installed, 0 to remove and 5 not upgraded.
null_resource.deploy_containers: Still creating... [10s elapsed]
null_resource.deploy_containers (remote-exec): DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
null_resource.deploy_containers (remote-exec):             Install the buildx component to build images with BuildKit:
null_resource.deploy_containers (remote-exec):             https://docs.docker.com/go/buildx/

null_resource.deploy_containers (remote-exec): Sending build context to Docker daemon  115.2kB
null_resource.deploy_containers (remote-exec): Step 1/4 : FROM php:8.1-apache
null_resource.deploy_containers (remote-exec):  ---> 9273bbba6cef
null_resource.deploy_containers (remote-exec): Step 2/4 : RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
null_resource.deploy_containers (remote-exec):  ---> Using cache
null_resource.deploy_containers (remote-exec):  ---> 20a596373c49
null_resource.deploy_containers (remote-exec): Step 3/4 : COPY . /var/www/html/
null_resource.deploy_containers (remote-exec):  ---> Using cache
null_resource.deploy_containers (remote-exec):  ---> bf3b56633f72
null_resource.deploy_containers (remote-exec): Step 4/4 : EXPOSE 80
null_resource.deploy_containers (remote-exec):  ---> Using cache
null_resource.deploy_containers (remote-exec):  ---> 403d046384ed
null_resource.deploy_containers (remote-exec): Successfully built 403d046384ed
null_resource.deploy_containers (remote-exec): Successfully tagged apache-container:latest
null_resource.deploy_containers (remote-exec): DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
null_resource.deploy_containers (remote-exec):             Install the buildx component to build images with BuildKit:
null_resource.deploy_containers (remote-exec):             https://docs.docker.com/go/buildx/

null_resource.deploy_containers (remote-exec): Sending build context to Docker daemon  115.2kB
null_resource.deploy_containers (remote-exec): Step 1/7 : FROM mysql:8.0
null_resource.deploy_containers (remote-exec):  ---> 6616596982ed
null_resource.deploy_containers (remote-exec): Step 2/7 : ENV MYSQL_ROOT_PASSWORD=metroid
null_resource.deploy_containers (remote-exec):  ---> Using cache
null_resource.deploy_containers (remote-exec):  ---> f331a86caf2a
null_resource.deploy_containers (remote-exec): Step 3/7 : ENV MYSQL_DATABASE=sre_desafio
null_resource.deploy_containers (remote-exec):  ---> Using cache
null_resource.deploy_containers (remote-exec):  ---> 7c2209178c78
null_resource.deploy_containers (remote-exec): Step 4/7 : ENV MYSQL_USER=admin
null_resource.deploy_containers (remote-exec):  ---> Using cache
null_resource.deploy_containers (remote-exec):  ---> 81bea6b45fd9
null_resource.deploy_containers (remote-exec): Step 5/7 : ENV MYSQL_PASSWORD=metroid
null_resource.deploy_containers (remote-exec):  ---> Using cache
null_resource.deploy_containers (remote-exec):  ---> 6d38f898e80c
null_resource.deploy_containers (remote-exec): Step 6/7 : COPY init.sql /docker-entrypoint-initdb.d/
null_resource.deploy_containers (remote-exec): COPY failed: file not found in build context or excluded by .dockerignore: stat init.sql: file does not exist
null_resource.deploy_containers (remote-exec): docker: Error response from daemon: Conflict. The container name "/apache-container" is already in use by container "deeec2b95c45f22117305409f0c7f0e87c2e1be85c3df5517d7d5a792307f768". You have to remove (or rename) that container to be able to reuse that name.
null_resource.deploy_containers (remote-exec): See 'docker run --help'.
null_resource.deploy_containers (remote-exec): 478cb50f4a0600d7ef76b93f4745715cab9e59eadb09907dbece9d1370d4cf8c
null_resource.deploy_containers (remote-exec): DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
null_resource.deploy_containers (remote-exec):             Install the buildx component to build images with BuildKit:
null_resource.deploy_containers (remote-exec):             https://docs.docker.com/go/buildx/

null_resource.deploy_containers (remote-exec): Sending build context to Docker daemon  3.072kB
null_resource.deploy_containers (remote-exec): Step 1/7 : FROM mysql:8.0
null_resource.deploy_containers (remote-exec):  ---> 6616596982ed
null_resource.deploy_containers (remote-exec): Step 2/7 : ENV MYSQL_ROOT_PASSWORD=metroid
null_resource.deploy_containers (remote-exec):  ---> Using cache
null_resource.deploy_containers (remote-exec):  ---> f331a86caf2a
null_resource.deploy_containers (remote-exec): Step 3/7 : ENV MYSQL_DATABASE=sre_desafio
null_resource.deploy_containers (remote-exec):  ---> Using cache
null_resource.deploy_containers (remote-exec):  ---> 7c2209178c78
null_resource.deploy_containers (remote-exec): Step 4/7 : ENV MYSQL_USER=admin
null_resource.deploy_containers (remote-exec):  ---> Using cache
null_resource.deploy_containers (remote-exec):  ---> 81bea6b45fd9
null_resource.deploy_containers (remote-exec): Step 5/7 : ENV MYSQL_PASSWORD=metroid
null_resource.deploy_containers (remote-exec):  ---> Using cache
null_resource.deploy_containers (remote-exec):  ---> 6d38f898e80c
null_resource.deploy_containers (remote-exec): Step 6/7 : COPY init.sql /docker-entrypoint-initdb.d/
null_resource.deploy_containers (remote-exec):  ---> Using cache
null_resource.deploy_containers (remote-exec):  ---> 1a1ca10986ad
null_resource.deploy_containers (remote-exec): Step 7/7 : EXPOSE 3306
null_resource.deploy_containers (remote-exec):  ---> Using cache
null_resource.deploy_containers (remote-exec):  ---> 0c63e71f6eb1
null_resource.deploy_containers (remote-exec): Successfully built 0c63e71f6eb1
null_resource.deploy_containers (remote-exec): Successfully tagged container-mysql:latest
null_resource.deploy_containers (remote-exec): mysql-container
null_resource.deploy_containers (remote-exec): mysql-container
null_resource.deploy_containers (remote-exec): dde8d3d073cfa8e1f279ca5dff8cc40b90f9e58166133fb56e0833ae5d2d8ddc
null_resource.deploy_containers: Creation complete after 19s [id=1573174304318784348]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

F:\terraform\desafio-terraform>
