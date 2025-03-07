provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-011e48799a29115e9" # AMI do Ubuntu 20.04
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_key.key_name
  security_groups = [aws_security_group.sre_sg.name] # ✅ Nome corrigido

  tags = {
    Name = "DesafioTerraform-EC2"
  }
}

resource "aws_security_group" "sre_sg" {
  name        = "sre_security_group"
  description = "Permitir acesso SSH, HTTP e MySQL"

  # ❌ Removendo vpc_id para usar a VPC padrão da AWS
  # Se quiser usar uma VPC específica, crie um `aws_vpc` antes e referencie aqui

  ingress {
    description = "Acesso SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["179.255.125.210/32"] # ⚠️ Permite SSH de qualquer lugar (idealmente, restrinja ao seu IP)
  }

  ingress {
    description = "Acesso HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Permite HTTP de qualquer lugar
  }

  ingress {
    description = "Acesso ao MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Idealmente, restrinja ao seu IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Permite saída para qualquer IP
  }
}
