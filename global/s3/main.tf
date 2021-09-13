# Configure the AWS Provider
terraform {
  # Chicken - egg catch.
  # First run with backend config disabled to create the AWS resources.
  backend "s3" {
    bucket         = "cgerull-terraform-state"
    region         = "eu-west-1"
    dynamodb_table = "cgerull-terraform-state-locks"
    encrypt        = true
    key            = "global/s3/terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.56"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "cgerull-terraform-state"

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }

  # Enable versioning
  versioning {
    enabled = true
  }

  # Enable server-side encrytion
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "cgerull-terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}