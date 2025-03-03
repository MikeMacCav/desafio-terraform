
🚀 Desafio SRE/DevOps - Configuração de Infraestrutura com Terraform e Deploy de Containers
Este repositório contém a configuração da infraestrutura utilizando Terraform, além da configuração de um servidor AWS EC2 para deploy de containers Docker.

📌 Passo a Passo - O que foi feito até agora
1️⃣ Configuração Inicial do Ambiente
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
2️⃣ Criação da Infraestrutura na AWS
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

Apliquei a configuração:

sh
Copiar
Editar
terraform init
terraform plan
terraform apply
3️⃣ Uso de Instância Existente ao invés de Criar uma Nova
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
Tentei importar a instância existente:
sh
Copiar
Editar
terraform import aws_instance.app_server i-0bb54181aed6221ec
⚠️ Erro encontrado: "resource address does not exist in the configuration".
🔹 Correção: Criei a configuração do recurso antes de importar.
4️⃣ Provisionamento e Deploy de Containers com Docker
Criei um provisionador remoto (remote-exec) para instalar o Docker e executar os containers:
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
Rodei terraform apply, mas encontrei um erro de SSH:
vbnet
Copiar
Editar
Error: remote-exec provisioner error
Failed to parse ssh private key: ssh: this private key is passphrase protected
⚠️ Problema: A chave privada está protegida por passphrase e o Terraform não consegue usá-la diretamente.
🔹 Solução: Precisei adicionar a chave ao ssh-agent ou criar uma nova sem passphrase.
5️⃣ Correção do Erro de Chave SSH
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
🚀 Próximos Passos
✅ Resolver o problema da chave SSH.
✅ Testar novamente o deploy com terraform apply.
⏳ Configurar volumes persistentes no MySQL.
⏳ Melhorar a organização dos Dockerfiles e adicionar um README.md no repositório do desafio.
📌 Status: Em andamento
📌 Tecnologias utilizadas:
✅ Terraform - Automação da infraestrutura
✅ AWS EC2 - Instância do servidor
✅ Docker - Deploy de containers
