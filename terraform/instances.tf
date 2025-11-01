resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = var.key_name # To load the public key uploaded in AWS EC2 into this instance for SSH access
  associate_public_ip_address = true # != EIP. It will always change upon reboot of the instance. Considering adding an EIP later

  # User data to set hostname
  user_data = <<-EOF # User data to set hostname
              #!/bin/bash
              hostnamectl set-hostname bastion.${var.domain_name}
              EOF

  tags = {
    Name    = "${var.project_name}-bastion"
    Project = var.project_name
    Role    = "Bastion"
  }
}


resource "aws_instance" "dns_server" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.dns_server.id]
  key_name               = var.key_name # To load the public key uploaded in AWS EC2 into this instance for SSH access
  private_ip = var.dns_server_ip
  
  # User data to set hostname
  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname ns1.${var.domain_name}
              echo "DNS server will be configured with BIND9"
              EOF

  tags = {
    Name    = "${var.project_name}-dns-server"
    Project = var.project_name
    Role    = "DNS"
  }


resource "aws_instance" "client1" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.clients.id]

  # User data to set hostname
  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname client1.${var.domain_name}
              EOF
  
  iam_instance_profile = aws_iam_instance_profile.client_ssm.name

  tags = {
    Name    = "${var.project_name}-client1"
    Project = var.project_name
    Role    = "Client"
  }
   

  # Ensure DNS server is running before clients (not strictly needed, but in case instances need to rely on DNS for installs or updates)
  depends_on = [aws_instance.dns_server]
}


resource "aws_instance" "client2" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.clients.id]

  # User data to set hostname
  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname client2.${var.domain_name}
              EOF
  
  iam_instance_profile = aws_iam_instance_profile.client_ssm.name

  tags = {
    Name    = "${var.project_name}-client2"
    Project = var.project_name
    Role    = "Client"
  }

  # Ensure DNS server is running before clients (not strictly needed, but in case instances need to rely on DNS for installs or updates)
  depends_on = [aws_instance.dns_server]
}

resource "aws_iam_instance_profile" "client_ssm" {
  name = "${var.project_name}-client-ssm-profile"
  role = aws_iam_role.client_ssm.name
  
  tags = {
    Name    = "${var.project_name}-client-ssm-profile"
    Project = var.project_name
  }
}

