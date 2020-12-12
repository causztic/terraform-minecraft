variable "aws_region" {
  description = "AWS Region"
  default = "ap-southeast-1"
}

variable "do_token" {
  description = "API token for digitalocean"
  type = string
  sensitive = true
}

variable "do_public_key_dir" {
  description = "public key directory location for digitalocean"
  type = string
  sensitive = true
}

# variable "do_region" {
#   description = "Region to create droplet in"
#   default = "sgp1"
# }

# variable "do_droplet_size" {
#   description = "Droplet Size"
#   default = "s-1vcpu-1gb"
# }