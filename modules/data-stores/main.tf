
data "aws_availability_zones" "available" {}

data "terraform_remote_state" "db" {
	backend = "s3"

	config {
    bucket = "${var.db_remote_state_bucket}"
    key    = "${var.db_remote_state_key}"
    region = "eu-west-2"
  }
}

resource "aws_db_instance" "example" {
  engine              = "mysql"
  allocated_storage   = 5
  instance_class      = "db.t2.micro"
  name                = "example_database"
  username            = "admin"
  password            = "${var.db_password}"
  skip_final_snapshot =  true
}
