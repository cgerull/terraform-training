terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.56"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

# Create a VPC
resource "aws_vpc" "training" {
  cidr_block = "10.0.0.0/16"
}


# Output
output "vpc-arn" {
  value = aws_vpc.training.arn
}
