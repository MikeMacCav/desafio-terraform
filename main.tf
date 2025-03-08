resource "aws_security_group" "sre_sg" {
  name        = "sre_security_group"
  description = "Permitir acesso SSH, HTTP e MySQL"

  ingress {
    description = "Acesso SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["179.255.125.210/32"] # Apenas meu IP
  }

  ingress {
    description = "Acesso HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Acesso ao MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface_sg_attachment" "attach_sg" {
  security_group_id    = aws_security_group.sre_sg.id
  network_interface_id = "eni-0ec195e19a6f0f785" 
}
