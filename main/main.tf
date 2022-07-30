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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.14.2"

  name               = "mc"
  cidr               = "10.10.10.0/24"
  azs                = ["ap-southeast-1a"]
  private_subnets    = ["10.10.10.0/27"]
  public_subnets     = ["10.10.10.96/27"]
  enable_nat_gateway = true
  single_nat_gateway = true
}

resource "aws_security_group" "mc" {
  name        = "Minecraft"
  description = "Allow public connections"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Minecraft port"
    from_port        = 25565
    to_port          = 25565
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private" {
  name        = "EFS"
  description = "Allow everything private"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
  }
}

resource "aws_efs_file_system" "minecraft" {}

resource "aws_efs_mount_target" "minecraft" {
  file_system_id  = aws_efs_file_system.minecraft.id
  subnet_id       = module.vpc.private_subnets[0]
  security_groups = [aws_security_group.private.id]
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
  platform_version = "1.4.0"

  task_definition = aws_ecs_task_definition.minecraft.arn

  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [aws_security_group.private.id, aws_security_group.mc.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "minecraft" {
  family                   = "minecraft"
  network_mode             = "awsvpc"
  container_definitions    = file("task-definitions/minecraft.json")

  requires_compatibilities = ["FARGATE"]
  memory                   = 2048
  cpu                      = 1024

  volume {
    name = "minecraft"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.minecraft.id
    }
  }
}
