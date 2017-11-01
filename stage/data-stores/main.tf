terraform {
  backend "s3" {
    bucket = "steviedons-terraform-up-and-running-state"
    key    = "stage/data-stores/terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
	region = "eu-west-2"
}

module "data-stores" {
  source = "../../modules/data-stores"

  db_remote_state_bucket  ="steviedons-terraform-up-and-running-state"
  db_remote_state_key     ="stage/data-stores/terraform.tfstate"
	db_password 						="password123"
}
