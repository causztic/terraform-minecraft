remote_state {
  backend = "s3"

  config = {
    bucket = "graf-tf-states"
    region = "ap-southeast-1"
    key    = "terraform.tfstate"
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

    provider "digitalocean" {
      token = var.do_token
    }
  EOF
}