# local-dns-bh
Cloud project. DNS in local network, with bastion host and SSM Session Manager
Local DNS Project: Secure Branch (Bastion-less SSM)

This branch implements a "Black Site" architecture for a private AWS environment. It removes the traditional Bastion host in favor of AWS Systems Manager (SSM) for management and uses VPC Endpoints for secure, private communication with AWS services.

🚀 Key Improvements

Bastion-less Management: No public-facing instances. Access is handled via SSM Interface Endpoints, reducing the attack surface.

Private Updates: OS updates and package installations (dnf/yum) are routed through an S3 Gateway Endpoint, keeping update traffic off the public internet.

Secure DNS Forwarding: A custom BIND server handles local lab.luigi queries and uses Conditional Forwarding to resolve AWS service names via the internal VPC Resolver.

🏗️ Architecture Overview

Traffic Flow

Management (SSM): Instances connect to SSM via Private Interface Endpoints (Port 443).

Updates (S3): All repository traffic is intercepted by the Gateway Endpoint and routed directly to S3.

DNS Resolution:

lab.luigi $\rightarrow$ Handled locally by BIND.

*.amazonaws.com $\rightarrow$ Forwarded to 169.254.169.253 (VPC Resolver).

Everything else $\rightarrow$ Forwarded to Google DNS (8.8.8.8) via NAT Gateway.

🛠️ Usage & Verification

1. Connecting to Instances

No SSH keys are required. Use the AWS CLI with the SSM plugin to connect via the instance IDs provided in your Terraform outputs:

# Connect to the DNS Server
aws ssm start-session --target <dns_instance_id>

# Connect to a Client
aws ssm start-session --target <client_instance_id>


2. Verifying Private DNS

Run dig on a client instance to ensure AWS services resolve to private IPs (Internal VPC range):

dig ssm.us-east-1.amazonaws.com
# Look for a 10.x.x.x address in the ANSWER section.


3. Verifying S3 Gateway

Test that you can reach the Amazon Linux repositories without a public route:

sudo dnf check-update


📝 Terraform Components

File

Description

vpc.tf

Defines the network, subnets, and NAT Gateway.

endpoints.tf

Configures the SSM Interface Endpoints and S3 Gateway Endpoint.

dns.tf & setup_dns.sh.tftpl

Configures the BIND server with forward-only rules for AWS domains.

security_groups.tf

Implements "Least Privilege" rules for instances and endpoints.