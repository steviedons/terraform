terraform {
  backend "s3" {
    bucket = "steviedons-terraform-up-and-running-state"
    key    = "stage/services/webserver-cluster/terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
	region = "eu-west-2"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name            = "webservers-stage"
  db_remote_state_bucket  = "steviedons-terraform-up-and-running-state"
  db_remote_state_key     = "stage/data-stores/terraform.tfstate"

}
