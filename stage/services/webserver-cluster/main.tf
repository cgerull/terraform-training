provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    key = "stage/services/webserver_cluster/terraform.tfstate"
  }
}

module "webserver_cluster" {
  source = "github.com/cgerull/terraform-modules-services-webserver-cluster?ref=v0.0.4"

  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "cgerull-terraform-state"
  db_remote_state_key    = "stage/services/webservice-cluster/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 1
  max_size      = 2
}