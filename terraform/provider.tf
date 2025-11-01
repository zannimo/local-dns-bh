terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "local-dns-bh-project"

  default_tags {
    tags = {
      Project = "local-dns-bh"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

