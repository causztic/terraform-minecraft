variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "ap-southeast-1"
}

variable "instance_type" {
  type        = string
  description = "Size of the server"
  default     = "t3a.small"
}

variable "aws_az" {
  type        = string
  description = "AWS AZ"
  default = "ap-southeast-1a"
}
variable "ec2_public_key" {
  sensitive   = true
  type        = string
  description = "Directory of public key to SSH into the EC2 instance"
}

variable "ec2_private_key" {
  sensitive   = true
  type        = string
  description = "Directory of private key for file provisioning to EC2"
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
  default     = "512M"
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
  sensitive   = true
  type        = string
  description = "Zone ID of the root domain"
}

variable "rcon_password" {
  type        = string
  description = "Password for rcon"
}

variable "discord_bot_token" {
  type        = string
  description = "Discord Bot Token"
}

variable "discord_channel_id" {
  type = string
  description = "Discord Channel ID"
}