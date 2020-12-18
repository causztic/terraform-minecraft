remote_state {
  backend = "s3"

  config = {
    bucket = "graf-tf-states"
    region = "ap-southeast-1"
    key    = "${path_relative_to_include()}/terraform.tfstate"
    encrypt = true

    dynamodb_table = "tf-locks"
  }
}

terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    arguments = [ "-var-file=../terraform.tfvars" ]
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
  provider "aws" {
    region = var.aws_region
  }
  provider "cloudflare" {
    api_token = var.cloudflare_api_token
  }
  EOF
}

generate "versions" {
  path = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
  terraform {
    required_version = ">= 0.14"
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 3.21"
      }
      cloudflare = {
        source  = "cloudflare/cloudflare"
        version = "~> 2.0"
      }
    }
  }
  EOF
}