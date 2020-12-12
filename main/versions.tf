terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.3.0"
    }
  }
}