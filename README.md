# **Local DNS with Bastion Host 🌐**

Decided to build **my own DNS server** in AWS rather than using the out-of-the-box AWS solutions. Good opportunity to practice and see what’s under the hood when it comes to domain resolution in general and in AWS. Previously I practiced DNS logic on Docker but on an Ubuntu distribution (see Docker folder for reference), while in AWS I used an Amazon Linux AMI (Red Hat).

Experimented accessing the instances via **Bastion Host** (the DNS server) as well as via **SSM Session Manager** (the 2 clients).

**Security**: while the proxy jump is rather secure with **SSH key pair**, and **security groups** follow the Principle of Least Privilege, all instances connect to the internet via NAT to retrieve OS updates.

In the other branch, “**secure-s3-version**”, I worked on some security improvement from an architectural standpoint: I ditched the Bastion Host in favor of SSM for all instances, and I connected them to S3 via prefix list to retrieve OS updates, rather than going out via the Internet via NAT. The NAT remained exclusively for DNS resolution forwarding (to the Google forwarder)

## **📁 Project Structure**

local-dns-bh/  
├── Docker/                 \# Local DNS logic testing (Ubuntu-based)  
│   ├── named.conf          \# BIND9 main configuration  
│   ├── db.lab.luigi        \# Zone file for local domain testing  
│   └── commands.md         \# Docker run/exec commands for lab testing  
├── terraform/              \# AWS Infrastructure (Amazon Linux 2023\)  
│   └── scripts/            \# Shell scripts and provisioning templates  
│       └── setup\_dns.sh.tftpl \# User data template for DNS server  
│   ├── data.tf             \# AMI and AWS data lookups  
│   ├── dhcp\_options.tf     \# DHCP custom configuration  
│   ├── iam.tf              \# Instance profiles for SSM access  
│   ├── instance.tf         \# EC2 instances (DNS Server, Clients, Bastion)  
│   ├── outputs.tf          \# Connection strings and IP addresses  
│   ├── providers.tf        \# AWS Provider configuration  
│   ├── security\_groups.tf  \# Firewall rules (Least Privilege)  
│   ├── vpc.tf              \# VPC, Subnets, and Routing  
│   ├── variables.tf        \# Input variable definitions  
│   └── terraform.tfvars    \# Environment-specific values (e.g., local IP)  
└── README.md

## **🏗️ Architecture Variants**

### **1\. Main Branch (Standard Architecture)**

The default deployment utilizes a classic three-tier inspired approach:

* **Networking**: VPC with Public and Private subnets across eu-central-1.  
* **Access**: A **Bastion Host** in the public subnet serves as the entry point via SSH.  
* **Egress**: A **NAT Gateway** provides the private instances with internet access for OS updates and package installation.  
* **Services**: A BIND9 DNS Server located at 10.0.2.10 providing resolution for the lab.luigi zone.

### **2\. Secure Branch (secure-s3-version)**

This version represents the "Hardened Architecture," focusing on reducing the attack surface and cost optimization:

* **Bastionless Access**: The Bastion host is removed. Secure shell access is managed entirely through **AWS Systems Manager (SSM) Session Manager**.  
* **Network Isolation**: The NAT Gateway is used exclusively for DNS resolution forwarding (to the Google forwarder).  
* **S3-Based Updates**: OS updates for Amazon Linux are routed through **S3 Interface Endpoints** using **AWS Prefix Lists**, allowing the instances to stay patched without requiring a direct route to the internet.

## **🛠️ Tech Stack**

* **Infrastructure**: Terraform  
* **Operating System**: Amazon Linux 2023 (AL2023)  
* **DNS Software**: BIND9 (Named)  
* **Containerization**: Docker (used for local testing of DNS logic)  
* **Cloud Provider**: AWS (SSM, VPC, EC2, S3 Endpoints)

## **🚀 Deployment Instructions**

### **Prerequisites**

* **Terraform & AWS CLI**: Installed and configured with appropriate permissions.  
* **SSH Key Pair**: Generate a key named local-dns-bh-key. The public key must be stored at \~/.ssh/local-dns-bh-key.pub for Terraform to upload it to AWS.  
  ssh-keygen \-t rsa \-b 4096 \-f \~/.ssh/local-dns-bh-key

* **Local IP Configuration**: You must set your current public IP address in terraform.tfvars to allow SSH access through the security groups.

### **Steps**

1. **Clone the main branch**:  
   git clone \[https://github.com/zannimo/local-dns-bh.git\](https://github.com/zannimo/local-dns-bh.git)

2. **Initialize Terraform**:  
   cd terraform  
   terraform init

3. **Configure Variables**:  
   Create or edit terraform.tfvars to include your specific environment settings:  
   my\_ip \= "x.x.x.x/32"  \# Your public IP address

4. **Apply Configuration**:  
   terraform apply

## **🔍 Verification**

Once deployed, verify the DNS resolution from a client instance:

\# Using SSM to connect (Secure version)  
aws ssm start-session \--target i-xxxxxxxxxxxx

\# Test resolution  
nslookup client2.lab.luigi  
