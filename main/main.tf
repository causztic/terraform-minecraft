terraform {
  backend "s3" {}
}

resource "aws_ecs_task_definition" "service" {
  family                = "service"
  container_definitions = file("task-definitions/service.json")

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [ap-southeast-1a, ap-southeast-1b, ap-southeast-1c]"
  }
}


resource "aws_ecs_service" "minecraft" {
  name            = "minecraft"
  task_definition = aws_ecs_task_definition.mongo.arn
  desired_count   = 1
}
