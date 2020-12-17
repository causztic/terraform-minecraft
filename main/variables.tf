variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "ap-southeast-1"
}

variable "instance_type" {
  type        = string
  description = "Size of the server"
  default     = "t3.nano"
}

variable "aws_az" {
  type        = string
  description = "AWS AZ"
  default = "ap-southeast-1a"
}
variable "ec2_public_key" {
  type        = string
  sensitive   = true
  description = "Public key of the keypair to SSH into the EC2 instance"
}

variable "device_name" {
  type        = string
  default     = "/dev/sdh"
  description = "Device name for EBS"
}