provider "aws" {
	region = "eu-west-2"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name            = "webservers-prrrof"
  db_remote_state_bucket  = "steviedons-terraform-up-and-running-state"
  db_remote_state_key     = "prod/data-stores/terraform.tfstate"

}
