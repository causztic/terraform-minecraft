variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "ap-southeast-1"
}

variable "instance_type" {
  type        = string
  description = "Size of the server"
  default     = "t3a.micro"
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

variable "min_memory" {
  type        = string
  default     = "512M"
  description = "Minimum memory for the server"
}
variable "max_memory" {
  type        = string
  default     = "960M"
  description = "Maximum memory for the server"
}

variable "cloudflare_email" {
  type        = string
  description = "Email of cloudflare account"
}

variable "cloudflare_api_token" {
  type        = string
  description = "API token to access the cloudflare account"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Zone ID of the root domain"
}