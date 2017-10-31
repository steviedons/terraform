variable "server_port" {
	description = "The port the server will listen on"
	default = 8080
}

variable "elb_port" {
	description = "The port the elb will listen on"
	default = 80
}
