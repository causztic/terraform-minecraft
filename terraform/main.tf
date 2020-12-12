provider "aws" {
  assume_role = "minecraft"
}

terraform {
  backend "s3" {
    key    = "minecraft"
    bucket = "graf-terraform-states"
    dynamodb_table = "remote-states"
    region = "ap-southeast-1"
  }
}