resource "aws_vpc_dhcp_options" "main" {
  domain_name = var.domain_name

  # My DNS server (BIND9) will be the primary one
  # AWS DNS resolver will be a fallback for AWS services
  domain_name_servers = [
    var.dns_server_ip,
    "AmazonProvidedDNS"
  ]

  tags = {
    Name    = "${var.project_name}-dhcp-options"
    Project = var.project_name
  }
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

