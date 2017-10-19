provider "aws" {
	region = "eu-west-2"
}

resource "aws_instance" "example" {
	ami 	      = "ami-62d7c206"
	instance_type = "t2.nano"

	tags {
		Name = "terraform-example"
     	}
}
