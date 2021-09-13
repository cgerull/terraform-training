terraform {
  backend "s3" {
    key = "stage/datastores/mysql/terraform.tfstate"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

data "aws_secretsmanager_secret_version" "stage_db_password" {
  secret_id = "stage-mysql-db"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.stage_db_password.secret_string
  )
}

resource "aws_db_instance" "stage_mysql_db" {
  identifier_prefix   = "cgerull-stage-"
  engine              = "mysql"
  engine_version      = 5.7
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  name                = "stage_mysql_db"
  skip_final_snapshot = true
  username            = "admin"
  password            = local.db_creds.master_password
}