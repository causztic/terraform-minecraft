terraform {
  backend "s3" {}
}

data "terraform_remote_state" "volume" {
  backend = "s3"

  config = {
    bucket = "graf-tf-states"
    key    = "volume/terraform.tfstate"
    region = "ap-southeast-1"
    dynamodb_table = "tf-locks"
  }
}

# resource "aws_ecs_task_definition" "service" {
#   family                = "service"
#   container_definitions = file("task-definitions/service.json")

#   volume {
#     name      = "service-storage"
#     host_path = "/usr/src/app"
#   }

#   placement_constraints {
#     type       = "memberOf"
#     expression = "attribute:ecs.availability-zone in [ap-southeast-1a, ap-southeast-1b, ap-southeast-1c]"
#   }
# }


# resource "aws_ecs_service" "minecraft" {
#   name            = "minecraft"
#   task_definition = aws_ecs_task_definition.service.arn
#   desired_count   = 1
# }
