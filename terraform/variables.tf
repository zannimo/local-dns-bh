variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "local-dns-bh"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "dns_server_ip" {
  description = "Static IP for DNS server"
  type        = string
  default     = "10.0.2.10"
}

variable "dns_forwarders" {
  description = "External DNS servers for forwarding"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]  # Google DNS
}

variable "domain_name" {
  description = "Internal domain name for the network"
  type        = string
  default     = "lab.luigi"
}

variable "my_ip" {
  description = "My public IP for SSH access"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair for EC2 access"
  type        = string
}

variable "ami_id" {
  description = "Amazon Linux 2023 kernel-6.1 AMI"
  type        = string
  default     = "ami-0854d4f8e4bd6b834"
}