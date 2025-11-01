resource "aws_security_group" "bastion" {
  name_prefix = "${var.project_name}-bastion-"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "SSH from allowed IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "SSH to DNS server"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.dns_server_ip] 
  }

  egress {
    description = "HTTPS for package updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Ubuntu repos
  }

  egress {
    description = "HTTP for package updates"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Ubuntu repos
  }

  egress {
    description = "DNS UDP to DNS server"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.dns_server_ip]
  }

  egress {
    description = "DNS TCP to DNS server"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.dns_server_ip]
  }

    egress {
    description = "NTP time sync to Amazon Time Sync Service"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = ["169.254.169.123/32"] 
}




   tags = {
    Name    = "${var.project_name}-bastion-sg"
    Project = var.project_name
  }
}

resource "aws_security_group" "dns_server" {
  name_prefix = "${var.project_name}-dns-"
  description = "Security group for DNS server"
  vpc_id      = aws_vpc.main.id

  # Allow SSH from bastion host
  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description = "DNS UDP from VPC"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "DNS TCP from VPC"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "DNS forwarding to public resolver"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["8.8.8.8/32", "8.8.4.4/32"]  # Google DNS
  }

  egress {
    description = "DNS TCP forwarding to public resolver"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["8.8.8.8/32", "8.8.4.4/32"]
  }

  egress {
    description = "HTTP for package updates"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

  egress {
    description = "NTP time sync"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = ["169.254.169.123/32"]  # AWS Time Sync Service
  }

    tags = {
    Name    = "${var.project_name}-dns-sg"
    Project = var.project_name
  }
}

resource "aws_security_group" "clients" {
  name_prefix = "${var.project_name}-clients-"
  description = "Security group for client instances"
  vpc_id      = aws_vpc.main.id

  # No ingress rules: using SSM Session Manager for access

  egress {
    description = "DNS UDP to DNS server"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.dns_server_ip]
  }

  egress {
    description = "DNS TCP to DNS server"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.dns_server_ip]
  }

  egress {
    description = "HTTPS for testing/updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP for testing/updates"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "NTP time sync"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = ["169.254.169.123/32"]
  }

   # SSM Agent outbound 
  egress {
    description = "SSM Agent outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Already covered by HTTPS, but explicit for clarity
  }

  tags = {
    Name    = "${var.project_name}-clients-sg"
    Project = var.project_name
  }
}