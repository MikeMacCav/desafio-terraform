
# 🚀 Desafio SRE/DevOps - Configuração de Infraestrutura com Terraform e Deploy de Containers
Este repositório contém a configuração da infraestrutura utilizando Terraform, além da configuração de um servidor AWS EC2 para deploy de containers Docker.

# 🛠 Passo a Passo
# 1️⃣ Configuração do Terraform
- Primeiro, defini a região da AWS onde minha instância será criada. Para isso, utilizei o seguinte código no arquivo main.tf:

- provider "aws" {
  - region = "us-east-1"
- }
# 2️⃣ Criação da Instância EC2
- Configurei a instância EC2 com a AMI do Ubuntu 20.04 e o tipo t2.micro. Também especifiquei a chave SSH e o grupo de segurança:

- resource "aws_instance" "app_server" {
  - ami           = "ami-011e48799a29115e9" # AMI do Ubuntu 20.04
  - instance_type = "t2.micro"
  - key_name      = aws_key_pair.ssh_key.key_name
  - security_groups = [aws_security_group.sre_sg.name]

  - tags = {
    - Name = "DesafioTerraform-EC2"
  - }
- }
# 3️⃣ Criação da Chave SSH
- Para acessar a instância de forma segura, gerei uma chave SSH e a adicionei ao Terraform:

- resource "aws_key_pair" "ssh_key" {
- key_name   = "terraform-key"
- public_key = file("~/.ssh/id_rsa.pub") # Substitua pelo caminho correto da chave pública
}
# 4️⃣ Configuração do Security Group
- Configurei um Security Group para permitir acessos essenciais:

- SSH (22): Restrito ao meu IP
- HTTP (80): Acesso liberado para qualquer IP
_ MySQL (3306): Acesso liberado para qualquer IP (mas posso restringir depois)

- resource "aws_security_group" "sre_sg" {
- name        = "sre_security_group"
- description = "Permitir acesso SSH, HTTP e MySQL"

 - ingress {
    - description = "Acesso SSH"
    - from_port   = 22
    - to_port     = 22
    - protocol    = "tcp"
    - cidr_blocks = ["MEU_IP/32"] # Meu IP público
  - }

  - ingress {
    - description = "Acesso HTTP"
    - from_port   = 80
    - to_port     = 80
    - protocol    = "tcp"
    - cidr_blocks = ["0.0.0.0/0"] # Acesso liberado
  - }

  - ingress {
    - description = "Acesso ao MySQL"
    - from_port   = 3306
    - to_port     = 3306
    - protocol    = "tcp"
    - cidr_blocks = ["0.0.0.0/0"] # Acesso liberado (por enquanto)
  - }

  - egress {
    - from_port   = 0
    - to_port     = 0
    - protocol    = "-1"
    - cidr_blocks = ["0.0.0.0/0"] # Permite saída para qualquer IP
  - }
- }
# 5️⃣ Deploy da Infraestrutura
- Após definir toda a configuração, rodei os seguintes comandos para provisionar os recursos na AWS:


- terraform init   # Inicializa o Terraform
- terraform apply -auto-approve   # Aplica as configurações automaticamente
- Com isso, o Terraform criou:
- ✅ Instância EC2
- ✅ Chave SSH
- ✅ Grupo de Segurança

# 6️⃣ Conectando à Instância
- Para acessar a instância, usei o comando:

- ssh -i terraform-key.pem ubuntu@MEU_IP_PUBLICO
# 7️⃣ Configuração do Docker na Instância
- Dentro da EC2, instalei o Docker para gerenciar os containers:

- sudo apt update && sudo apt install -y docker.io
- sudo systemctl enable docker
- sudo systemctl start docker
- Verifiquei se o Docker estava rodando corretamente:
- docker --version


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

# 📌 Atualização: 07/03/2025 - Grupo de Segurança aplicado com restrinção de IP.
# Print da restrinção:
![image](https://github.com/user-attachments/assets/9653175d-23a9-4348-b56c-73cc9d0d5984)

# Relatório completo da restrinção:
- F:\terraform\desafio-terraform>terraform apply -auto-approve
- aws_security_group.instance_sg: Refreshing state... [id=sg-0c98dd5ff33ab0e6e]
- aws_security_group.sre_sg: Refreshing state... [id=sg-00b4b91bda1f2a5ea]
- aws_instance.app_server: Refreshing state... [id=i-0248580a70576caa3]
- aws_key_pair.ssh_key: Refreshing state... [id=terraform-key]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  - destroy

Terraform will perform the following actions:

  # aws_instance.app_server will be destroyed
  # (because aws_instance.app_server is not in configuration)
  - resource "aws_instance" "app_server" {
      - ami                                  = "ami-011e48799a29115e9" -> null
      - arn                                  = "arn:aws:ec2:us-east-1:908027403552:instance/i-0248580a70576caa3" -> null
      - associate_public_ip_address          = true -> null
      - availability_zone                    = "us-east-1b" -> null
      - cpu_core_count                       = 1 -> null
      - cpu_threads_per_core                 = 1 -> null
      - disable_api_stop                     = false -> null
      - disable_api_termination              = false -> null
      - ebs_optimized                        = false -> null
      - get_password_data                    = false -> null
      - hibernation                          = false -> null
      - id                                   = "i-0248580a70576caa3" -> null
      - instance_initiated_shutdown_behavior = "stop" -> null
      - instance_state                       = "running" -> null
      - instance_type                        = "t2.micro" -> null
      - ipv6_address_count                   = 0 -> null
      - ipv6_addresses                       = [] -> null
      - key_name                             = "terraform-key" -> null
      - monitoring                           = false -> null
      - placement_partition_number           = 0 -> null
      - primary_network_interface_id         = "eni-0d46374ea4a2679df" -> null
      - private_dns                          = "ip-172-31-90-78.ec2.internal" -> null
      - private_ip                           = "172.31.90.78" -> null
      - public_dns                           = "ec2-18-212-21-45.compute-1.amazonaws.com" -> null
      - public_ip                            = "18.212.21.45" -> null
      - secondary_private_ips                = [] -> null
      - security_groups                      = [
          - "sre_security_group",
        ] -> null
      - source_dest_check                    = true -> null
      - subnet_id                            = "subnet-045676d0f71462abd" -> null
      - tags                                 = {
          - "Name" = "DesafioTerraform-EC2"
        } -> null
      - tags_all                             = {
          - "Name" = "DesafioTerraform-EC2"
        } -> null
      - tenancy                              = "default" -> null
      - user_data_replace_on_change          = false -> null
      - vpc_security_group_ids               = [
          - "sg-00b4b91bda1f2a5ea",
        ] -> null
        # (7 unchanged attributes hidden)

      - capacity_reservation_specification {
          - capacity_reservation_preference = "open" -> null
        }

      - cpu_options {
          - core_count       = 1 -> null
          - threads_per_core = 1 -> null
            # (1 unchanged attribute hidden)
        }

      - credit_specification {
          - cpu_credits = "standard" -> null
        }

      - enclave_options {
          - enabled = false -> null
        }

      - maintenance_options {
          - auto_recovery = "default" -> null
        }

      - metadata_options {
          - http_endpoint               = "enabled" -> null
          - http_protocol_ipv6          = "disabled" -> null
          - http_put_response_hop_limit = 1 -> null
          - http_tokens                 = "optional" -> null
          - instance_metadata_tags      = "disabled" -> null
        }

      - private_dns_name_options {
          - enable_resource_name_dns_a_record    = false -> null
          - enable_resource_name_dns_aaaa_record = false -> null
          - hostname_type                        = "ip-name" -> null
        }

      - root_block_device {
          - delete_on_termination = true -> null
          - device_name           = "/dev/sda1" -> null
          - encrypted             = false -> null
          - iops                  = 100 -> null
          - tags                  = {} -> null
          - tags_all              = {} -> null
          - throughput            = 0 -> null
          - volume_id             = "vol-09c3e27d6b61005bf" -> null
          - volume_size           = 8 -> null
          - volume_type           = "gp2" -> null
            # (1 unchanged attribute hidden)
        }
    }

  # aws_network_interface_sg_attachment.attach_sg will be created
  + resource "aws_network_interface_sg_attachment" "attach_sg" {
      + id                   = (known after apply)
      + network_interface_id = "eni-0ec195e19a6f0f785"
      + security_group_id    = "sg-00b4b91bda1f2a5ea"
    }

Plan: 1 to add, 0 to change, 1 to destroy.
aws_instance.app_server: Destroying... [id=i-0248580a70576caa3]
aws_network_interface_sg_attachment.attach_sg: Creating...
aws_network_interface_sg_attachment.attach_sg: Creation complete after 2s [id=sg-00b4b91bda1f2a5ea_eni-0ec195e19a6f0f785]
                                              aws_instance.app_server: Still destroying... [id=i-0248580a70576caa3, 10s elapsed]
aws_instance.app_server: Destruction complete after 12s

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

# Deploy 14/03/2025:
![image](https://github.com/user-attachments/assets/9d7d613c-4b14-4bb0-b6dd-a9a421b8d01b)

# Relatório completo:
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.app_server: Modifying... [id=i-0bb54181aed6221ec]
aws_instance.app_server: Modifications complete after 4s [id=i-0bb54181aed6221ec]
null_resource.deploy_docker: Creating...
null_resource.deploy_docker: Provisioning with 'remote-exec'...
null_resource.deploy_docker: Still creating... [10s elapsed]
null_resource.deploy_docker: Still creating... [20s elapsed]
null_resource.deploy_docker: Still creating... [30s elapsed]
null_resource.deploy_docker (remote-exec): Connecting to remote host via SSH...
null_resource.deploy_docker (remote-exec):   Host: 52.90.66.194
null_resource.deploy_docker (remote-exec):   User: ubuntu
null_resource.deploy_docker (remote-exec):   Password: false
null_resource.deploy_docker (remote-exec):   Private key: true
null_resource.deploy_docker (remote-exec):   Certificate: false
null_resource.deploy_docker (remote-exec):   SSH Agent: false
null_resource.deploy_docker (remote-exec):   Checking Host Key: false
null_resource.deploy_docker (remote-exec):   Target Platform: unix
null_resource.deploy_docker (remote-exec): Connected!
null_resource.deploy_docker (remote-exec): DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
null_resource.deploy_docker (remote-exec):             Install the buildx component to build images with BuildKit:
null_resource.deploy_docker (remote-exec):             https://docs.docker.com/go/buildx/

null_resource.deploy_docker (remote-exec): Sending build context to Docker daemon  10.24kB
null_resource.deploy_docker (remote-exec): Step 1/4 : FROM php:8.1-apache
null_resource.deploy_docker (remote-exec):  ---> 9273bbba6cef
null_resource.deploy_docker (remote-exec): Step 2/4 : RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
null_resource.deploy_docker (remote-exec):  ---> Using cache
null_resource.deploy_docker (remote-exec):  ---> 20a596373c49
null_resource.deploy_docker (remote-exec): Step 3/4 : COPY . /var/www/html/
null_resource.deploy_docker (remote-exec):  ---> 788ba47ecd2e
null_resource.deploy_docker (remote-exec): Step 4/4 : EXPOSE 80
null_resource.deploy_docker (remote-exec):  ---> Running in e0ca93d40f64
null_resource.deploy_docker (remote-exec):  ---> Removed intermediate container e0ca93d40f64
null_resource.deploy_docker (remote-exec):  ---> 8adf4b4a3c51
null_resource.deploy_docker (remote-exec): Successfully built 8adf4b4a3c51
null_resource.deploy_docker (remote-exec): Successfully tagged apache-container:latest
null_resource.deploy_docker (remote-exec): DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
null_resource.deploy_docker (remote-exec):             Install the buildx component to build images with BuildKit:
null_resource.deploy_docker (remote-exec):             https://docs.docker.com/go/buildx/

null_resource.deploy_docker (remote-exec): Sending build context to Docker daemon  3.072kB
null_resource.deploy_docker (remote-exec): Step 1/7 : FROM mysql:8.0
null_resource.deploy_docker (remote-exec):  ---> 6616596982ed
null_resource.deploy_docker (remote-exec): Step 2/7 : ENV MYSQL_ROOT_PASSWORD=metroid
null_resource.deploy_docker (remote-exec):  ---> Using cache
null_resource.deploy_docker (remote-exec):  ---> f331a86caf2a
null_resource.deploy_docker (remote-exec): Step 3/7 : ENV MYSQL_DATABASE=sre_desafio
null_resource.deploy_docker (remote-exec):  ---> Using cache
null_resource.deploy_docker (remote-exec):  ---> 7c2209178c78
null_resource.deploy_docker (remote-exec): Step 4/7 : ENV MYSQL_USER=admin
null_resource.deploy_docker (remote-exec):  ---> Using cache
null_resource.deploy_docker (remote-exec):  ---> 81bea6b45fd9
null_resource.deploy_docker (remote-exec): Step 5/7 : ENV MYSQL_PASSWORD=metroid
null_resource.deploy_docker (remote-exec):  ---> Using cache
null_resource.deploy_docker (remote-exec):  ---> 6d38f898e80c
null_resource.deploy_docker (remote-exec): Step 6/7 : COPY init.sql /docker-entrypoint-initdb.d/
null_resource.deploy_docker (remote-exec):  ---> Using cache
null_resource.deploy_docker (remote-exec):  ---> 1a1ca10986ad
null_resource.deploy_docker (remote-exec): Step 7/7 : EXPOSE 3306
null_resource.deploy_docker (remote-exec):  ---> Using cache
null_resource.deploy_docker (remote-exec):  ---> 0c63e71f6eb1
null_resource.deploy_docker (remote-exec): Successfully built 0c63e71f6eb1
null_resource.deploy_docker (remote-exec): Successfully tagged container-mysql:latest
null_resource.deploy_docker (remote-exec): cc0103b6ee2b5fbbb9d1607d8b749e4a0cc54737e6a3c16d02604ae30aa9c93b
null_resource.deploy_docker (remote-exec): 9159b5cbd262b3c28ee75864b22e50fab37f3455758fb69a38eb0a4f72161e05
null_resource.deploy_docker: Creation complete after 39s [id=5201739934233569110]

Apply complete! Resources: 1 added, 1 changed, 0 destroyed.
