resource "aws_security_group" "dns_server" {
  name_prefix = "${var.project_name}-dns-"
  description = "Security group for DNS server"
  vpc_id      = aws_vpc.main.id

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
    cidr_blocks = ["8.8.8.8/32", "8.8.4.4/32"] # Google DNS forwarder
  }

  egress {
    description = "DNS TCP forwarding to public resolver"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["8.8.8.8/32", "8.8.4.4/32"]
  }

  egress {
    description     = "HTTP for package install and updates via S3 gateway endpoint"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [data.aws_prefix_list.s3.id]
  }

  egress {
    description = "NTP time sync"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = ["169.254.169.123/32"] # AWS Time Sync Service
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
    cidr_blocks = ["${var.dns_server_ip}/32"]
  }

  egress {
    description = "DNS TCP to DNS server"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["${var.dns_server_ip}/32"]
  }

  egress {
    description     = "HTTP for package install and updates via S3 gateway endpoint"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [data.aws_prefix_list.s3.id]
  }

  egress {
    description = "NTP time sync"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = ["169.254.169.123/32"]
  }

  tags = {
    Name    = "${var.project_name}-clients-sg"
    Project = var.project_name
  }
}

resource "aws_security_group" "vpc_endpoint" {
  name_prefix = "${var.project_name}-vpc_endpoint-"
  description = "Security group for VPC endpoint"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-vpc_endpoint-sg"
    Project = var.project_name
  }
}

# Separate rules to avoid Cycle errors

resource "aws_security_group_rule" "endpoint_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main.cidr_block] # Everyone in the VPC can connect
  security_group_id = aws_security_group.vpc_endpoint.id
}

resource "aws_security_group_rule" "dns_server_egress_to_ssm" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.dns_server.id
}

resource "aws_security_group_rule" "clients_egress_to_ssm" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.clients.id
}