
provider "aws" {
	region = "eu-west-2"
}

variable "server_port" {
	description = "The port the server will listen on"
	default = 8080
}

resource "aws_instance" "example" {
    # This is the Ubuntu ami
		ami   	      = "ami-996372fd"
		instance_type = "t2.nano"
    key_name      = "steve-titan"
		vpc_security_group_ids = ["${aws_security_group.instance.id}"]
    user_data     = <<-EOF
                    #!/bin/bash
                    echo "Hello, World" > index.html
                    nohup busybox httpd -f -p "${var.server_port}" &
                    EOF

    tags {
		Name = "terraform-example"
     	}
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"
    ingress {
				from_port = "${var.server_port}"
	    	to_port = "${var.server_port}"
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}

resource "aws_key_pair" "steve-titan" {
  key_name   = "steve-titan"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/3ZU3FLKqkK+lNO/Uzuzvnexc6CDSYaEC5U+ndSVAJW8UuxWZSVY34MwrSagSex7EW3M/uBI+twXIB/pqER/OjtUkrw8AV8SbX2EU1SAGquMUw6njUK51loDd5T42xuavdKR9tn8yfW8mmDmKZe/ZyXPhlKkcZ5xvwqjdi0JWp9VP58FV64Iq+rb805icUuLqVI0L/EaeVNgbM7EXZdXVBom+sKXnvh8OE1STa11v8o/NHGf3/BRFQpqEe1ESgqQ936onWpD8e44brJjW9l8ZXhPDqMnVCu7kHQLhvF3kbSWTjr+OlabUKM5ZgfVrXxJmGaUpu18nca3Kk/XQoX03 steve@titan"
}

output "public_ip" {
	value = "${aws_instance.example.public_ip}"
}
