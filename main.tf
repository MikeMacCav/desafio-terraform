provider "aws" {
  region = "us-east-1"
}

# Dados da instância já existente
data "aws_instance" "app_server" {
  instance_id = "i-0bb54181aed6221ec"
}

# Provisionamento do Docker e Deploy dos Containers
resource "null_resource" "deploy_containers" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("F:/terraform/keys/terraform-key") # Caminho da chave privada
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

