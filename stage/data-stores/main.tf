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

data "aws_availability_zones" "available" {}

data "terraform_remote_state" "stage" {
  backend = "s3"
  config {
    bucket = "steviedons-terraform-up-and-running-state"
    key    = "stage/data-stores/terraform.tfstate"
    region = "eu-west-2"
  }
}

resource "aws_db_instance" "example" {
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "example_database"
  username          = "admin"
  password          = "${var.db_password}"
}
