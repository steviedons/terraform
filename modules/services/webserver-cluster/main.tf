# The s3 bucket configuration does not match the book and was taken from
# the documentation https://www.terraform.io/docs/backends/types/s3.html
# a terraform init was needed to initalize the bucket.

terraform {
  backend "s3" {
    bucket = "steviedons-terraform-up-and-running-state"
    key    = "stage/services/webserver-cluster/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "aws_availability_zones" "available" {}

data "terraform_remote_state" "stage" {
  backend = "s3"
  config {
    bucket = "steviedons-terraform-up-and-running-state"
    key    = "stage/services/webserver-cluster/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "db" {
	backend = "s3"

	config {
    bucket = "steviedons-terraform-up-and-running-state"
    key    = "stage/data-stores/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "template_file" "user_data" {
	template = "${file("${path.module}/user-data.sh")}"

	vars {
		server_port = "${var.server_port}"
		db_address	=	"${data.terraform_remote_state.db.address}"
		db_port			= "${data.terraform_remote_state.db.port}"
	}
}

resource "aws_launch_configuration" "example" {
    # This is the Ubuntu ami
	name_prefix   					= "terraform-lc-example-"
	image_id   	      			= "ami-996372fd"
	instance_type 					= "t2.nano"
	security_groups 				= ["${aws_security_group.instance.id}"]
	key_name 								= "deployer-key"
	user_data 							= "${data.template_file.user_data.rendered}"

	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC//pH6SLKzy5iWlzbpX1yMY6AkkiJrRtCLVynzKK9ksalFL9akH/RlgeSHz3X+C2tPel2XnrUAY4Pl4yX38Ogzh5cIJxkrxXS5eA03+hZ5Q6gHzg4JVH7omftQgFkhW5wrFFn9mnMkmmI3Ix++LmYYNMgHwiphikWYQfHBwUUN7w4vCVpjJFIoL+P4wmOday5ymxJAc3e20HnmB760ODAblPT1SM8T5y+wZg762DFp7Tnba0unW7wdfkc2lL9vT/YyivnnL3gU8MfD6JyCP8GZhfcCGyD+7rNG9ZGIhbYLuEyuOhkE4dkpOTSnKpSlWpnQkrpBsh6pZePTQOnM5nzt steve@pixel"
}


resource "aws_security_group" "instance" {
	name = "terraform-example-instance"

  ingress {
		from_port 		= "${var.server_port}"
		to_port 			= "${var.server_port}"
  	protocol 			= "tcp"
    cidr_blocks 	= [ "0.0.0.0/0" ]
  }

	ingress {
		from_port 		= 22
		to_port 			= 22
  	protocol 			= "tcp"
    cidr_blocks 	= [ "212.159.22.24/32" ]
  }

	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_security_group" "elb" {
	name = "terraform-example-elb"

	ingress {
		from_port 		= "${var.elb_port}"
		to_port 			= "${var.elb_port}"
  	protocol 			= "tcp"
    cidr_blocks 	= [ "0.0.0.0/0" ]
	}

	egress {
		from_port 		= 0
		to_port 			= 0
		protocol 			= "-1"
		cidr_blocks 	= [ "0.0.0.0/0" ]
	}
}

resource "aws_autoscaling_group" "example" {
	launch_configuration 	= "${aws_launch_configuration.example.id}"
	availability_zones 		=	["${data.aws_availability_zones.available.names}"]

	load_balancers 		=	["${aws_elb.example.name}"]
	health_check_type = "ELB"

	min_size = 2
	max_size = 10

	tag {
		key 							  = "Name"
		value 						  = "terraform-asg-example"
		propagate_at_launch = true
	}
}

resource "aws_elb" "example" {
	name 								= "terraform-asg-example"
	availability_zones 	= ["${data.aws_availability_zones.available.names}"]
	security_groups 		= ["${aws_security_group.elb.id}"]

	listener {
		lb_port 						= 80
		lb_protocol 				= "http"
		instance_port 			= "${var.server_port}"
		instance_protocol 	= "http"
	}

	health_check {
	  healthy_threshold 	= 2
	  unhealthy_threshold = 2
	  timeout 						= 3
	  target 							= "HTTP:${var.server_port}/"
	  interval 						= 30
	}
}
