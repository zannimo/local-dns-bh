data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"] # Official Amazon AMIs

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# This fetches the unique Prefix List ID for S3 in your current region
data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${var.aws_region}.s3"
}