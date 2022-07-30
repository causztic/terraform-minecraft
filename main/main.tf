terraform {
  backend "s3" {}
}

# TODO: Add cloudwatch rule to get task Public IP to update cloudflare
#
# resource "cloudflare_record" "minecraft" {
#   zone_id = var.cloudflare_zone_id
#   name = "mc"
#   value = aws_ecs_service.minecraft.public_ip
#   type = "A"
#   depends_on = [aws_ecs_service.minecraft]
# }

data "terraform_remote_state" "volume" {
  backend = "s3"

  config = {
    bucket = "graf-tf-states"
    key    = "volume/terraform.tfstate"
    region = "ap-southeast-1"
    dynamodb_table = "tf-locks"
  }
}

resource "aws_efs_file_system" "minecraft" {}

resource "aws_efs_mount_target" "minecraft" {
  file_system_id  = aws_efs_file_system.minecraft.id
  subnet_id       = aws_subnet.public.id
}

resource "aws_ecs_cluster" "minecraft" {
  name = "minecraft"
}

resource "aws_ecs_cluster_capacity_providers" "minecraft" {
  cluster_name = aws_ecs_cluster.minecraft.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_ecs_service" "minecraft" {
  name          = "minecraft"
  cluster       = aws_ecs_cluster.minecraft.id
  desired_count = 1
  launch_type   = "FARGATE"

  task_definition = aws_ecs_task_definition.minecraft.arn

  network_configuration {
    subnets = [aws_subnet.public.id]
    security_groups = [aws_security_group.minecraft.id]
    # assign_public_ip = true
  }
}

data "aws_iam_policy" "ecs" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy" "log" {
  name = "CloudWatchLogsFullAccess"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  managed_policy_arns = [data.aws_iam_policy.ecs.arn, data.aws_iam_policy.log.arn]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_ecs_task_definition" "minecraft" {
  family                   = "minecraft"
  network_mode             = "awsvpc"
  container_definitions    = file("task-definitions/minecraft.json")

  requires_compatibilities = ["FARGATE"]
  memory                   = 2048
  cpu                      = 1024

  execution_role_arn       = resource.aws_iam_role.ecs_task_execution_role.arn

  volume {
    name = "minecraft"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.minecraft.id
    }
  }
}
