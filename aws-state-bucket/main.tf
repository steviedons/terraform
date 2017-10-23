provider "aws" {
	region = "eu-west-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "steviedons-terraform-up-and-running-state"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
