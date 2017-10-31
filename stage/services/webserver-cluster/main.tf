provider "aws" {
	region = "eu-west-2"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"
}
