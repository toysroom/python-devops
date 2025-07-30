provider "aws" {
  region = var.region
}

# Creazione della VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.resource_group_name
  }
}

# Creazione della subnet
resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "jenkins-subnet"
  }
}

# Creazione del Security Group (corrisponde a Network Security Group in Azure)
resource "aws_security_group" "sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from anywhere"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Jenkins (port 8080) from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "jenkins-sg"
  }
}

# Creazione della Internet Gateway per la connettività pubblica
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "jenkins-igw"
  }
}

# Creazione dell'IP pubblico elastico (corrisponde a Public IP in Azure)
resource "aws_eip" "jenkins_ip" {
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = "jenkins-public-ip"
  }
}

# Creazione della Route Table e associazione alla subnet
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "jenkins-rt"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}


## Definizioni IAM per la VM

# 1. Crea una Politica IAM che definisce i permessi (es. permessi per EC2, S3, ecc.)
resource "aws_iam_policy" "terraform_ec2_policy" {
  name        = "TerraformEC2Policy"
  description = "Permessi per Terraform per gestire le risorse EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",
          "ec2:StopInstances",
          "ec2:StartInstances",
          "s3:ListBucket",
          "ecr:GetAuthorizationToken",
          # Aggiungi qui tutti i permessi necessari a Terraform per deployare le tue risorse
        ]
        Effect   = "Allow"
        Resource = "*" # ATTENZIONE: In produzione, limita sempre le risorse specifiche
      },
    ]
  })
}

# 2. Crea un Ruolo IAM
resource "aws_iam_role" "terraform_ec2_role" {
  name = "TerraformEC2Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" # Questo permette solo alle istanze EC2 di assumere questo ruolo
        }
      },
    ]
  })
}

# 3. Associa la Politica al Ruolo
resource "aws_iam_role_policy_attachment" "terraform_role_attachment" {
  role       = aws_iam_role.terraform_ec2_role.name
  policy_arn = aws_iam_policy.terraform_ec2_policy.arn
}

# 4. Crea un Instance Profile (necessario per associare il ruolo a una EC2)
resource "aws_iam_instance_profile" "terraform_ec2_profile" {
  name = "TerraformEC2Profile"
  role = aws_iam_role.terraform_ec2_role.name
}

# Crea la key pair SSH in AWS
resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins-key" # Deve corrispondere al key_name nella tua aws_instance.vm
  public_key = file("~/.ssh/jenkins_id_rsa.pub") # Assicurati che il percorso sia corretto!
}

# Creazione della EC2 Instance (corrisponde a Linux Virtual Machine in Azure)
resource "aws_instance" "vm" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro" # Corrisponde a Standard_B2s, un'istanza di dimensioni simili
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name                    = "jenkins-key"

  # Associa l'Instance Profile alla VM
  iam_instance_profile = aws_iam_instance_profile.terraform_ec2_profile.name

  tags = {
    Name = "jenkins-vm"
  }
}

# Associazione dell'IP elastico alla VM
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.vm.id
  allocation_id = aws_eip.jenkins_ip.id
}

# Data source per ottenere l'AMI più recente di Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's owner ID for Ubuntu AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Creazione ECR (Elastic Container Registry) - corrisponde a ACR (Azure Container Registry)
resource "aws_ecr_repository" "ecr" {
  name = var.acr_name
  tags = {
    Name = var.acr_name
  }
}

# Creazione di un Elastic Beanstalk Application (corrisponde ad App Service/Web App in Azure)
resource "aws_elastic_beanstalk_application" "flask_app_service" {
  name        = "flask-app-eb"
  description = "Elastic Beanstalk application for Flask app"
  tags = {
    Name = "flask-app-eb"
  }
}