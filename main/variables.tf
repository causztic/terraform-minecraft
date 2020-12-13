variable "aws_region" {
  description = "AWS Region"
  default = "ap-southeast-1"
}

variable "instance_type" {
  description = "Size of the server"
  default = "t3.nano"
}

variable "aws_az" {
  description = "AWS AZ"
  default = "ap-southeast-1a"
}