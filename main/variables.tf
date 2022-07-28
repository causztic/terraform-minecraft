variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "ap-southeast-1"
}

variable "aws_az" {
  type        = string
  description = "AWS AZ"
  default = "ap-southeast-1a"
}

variable "mc_version" {
  type        = string
  description =  "Version of the server"
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

variable "discord_bot_token" {
  type        = string
  description = "Discord Bot Token"
}

variable "discord_channel_id" {
  type = string
  description = "Discord Channel ID"
}