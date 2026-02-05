resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = var.key_name # To load the public key uploaded in AWS EC2 into this instance for SSH access
  associate_public_ip_address = true         # != EIP. It will always change upon reboot of the instance. Considering adding an EIP later

  # User data to set hostname
  user_data = <<-EOF
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
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.dns_server.id]
  key_name               = var.key_name # To load the public key uploaded in AWS EC2 into this instance for SSH access
  private_ip             = var.dns_server_ip

  # User data to set hostname and DNS server
  user_data = templatefile("${path.module}/scripts/setup_dns.sh.tftpl", {
    client1_ip    = aws_instance.client1.private_ip
    client2_ip    = aws_instance.client2.private_ip
    dns_server_ip = var.dns_server_ip
    vpc_cidr      = var.vpc_cidr
  })

  tags = {
    Name    = "${var.project_name}-dns-server"
    Project = var.project_name
    Role    = "DNS"
  }
}

resource "aws_instance" "client1" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.clients.id]
  private_ip             = "10.0.2.21"

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
}


resource "aws_instance" "client2" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.clients.id]
  private_ip             = "10.0.2.22"

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
}

resource "aws_iam_instance_profile" "client_ssm" {
  name = "${var.project_name}-client-ssm-profile"
  role = aws_iam_role.client_ssm.name

  tags = {
    Name    = "${var.project_name}-client-ssm-profile"
    Project = var.project_name
  }
}

