resource "aws_instance" "dns_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.dns_server.id]
  private_ip             = var.dns_server_ip

  # User data to set hostname and DNS server
  user_data = templatefile("${path.module}/scripts/setup_dns.sh.tftpl", {
    client1_ip    = aws_instance.client1.private_ip
    client2_ip    = aws_instance.client2.private_ip
    dns_server_ip = var.dns_server_ip
    vpc_cidr      = var.vpc_cidr
  })

  iam_instance_profile = aws_iam_instance_profile.client_ssm.name

  depends_on = [
    aws_vpc_endpoint.s3
  ]

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

              # Install networking tools for verification
              dnf update -y
              dnf install -y bind-utils
              EOF

  iam_instance_profile = aws_iam_instance_profile.client_ssm.name

  depends_on = [
    aws_vpc_endpoint.s3
  ]

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
              hostnamectl set-hostname client1.${var.domain_name}

              # Install networking tools for verification
              dnf update -y
              dnf install -y bind-utils
              EOF

  iam_instance_profile = aws_iam_instance_profile.client_ssm.name

  depends_on = [
    aws_vpc_endpoint.s3
  ]

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

