provider "aws" {
  region = var.region
}

module "webserver_cluster" {
  source = "../../../modules/services/webservices"

  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "cgerull-terraform-state"
  db_remote_state_key    = "stage/services/webservice-cluster/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 2
}