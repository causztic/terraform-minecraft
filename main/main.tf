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

resource "aws_ecs_task_definition" "service" {
  family                = "service"
  container_definitions = file("task-definitions/service.json")
  requires_compatibilities = [ "EC2" ]

  volume {
    name = "minecraft-volume"

    docker_volume_configuration {
      scope = "shared"
      autoprovision = "false"
      driver = "rexray/ebs"
      driver_opts = {
        volumeID = data.terraform_remote_state.volume.outputs.ebs_volume_id
      }
    }
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [ap-southeast-1a, ap-southeast-1b, ap-southeast-1c]"
  }
}


# resource "aws_ecs_service" "minecraft" {
#   name            = "minecraft"
#   task_definition = aws_ecs_task_definition.service.arn
#   desired_count   = 1
# }
