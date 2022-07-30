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

  name                 = "mc"
  cidr                 = "10.10.10.0/24"
  azs                  = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]

  private_subnets      = ["10.10.10.128/27"]
  public_subnets       = ["10.10.10.96/27"]
  # intra_subnets        = ["10.10.10.0/27"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
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

  ingress {
    description      = "Image pulling"
    from_port        = 443
    to_port          = 443
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

resource "aws_security_group" "intra" {
  name        = "intra"
  description = "Allow everything to move around in intranet"
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
  security_groups = [aws_security_group.intra.id]
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
    subnets = module.vpc.private_subnets
    security_groups = [aws_security_group.intra.id, aws_security_group.mc.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "minecraft" {
  family                   = "minecraft"
  network_mode             = "awsvpc"
  container_definitions    = file("task-definitions/minecraft.json")
  // "logConfiguration": {
  //   "logDriver": "awslogs",
  //   "options": {
  //       "awslogs-group": "mc",
  //       "awslogs-region": "ap-southeast-1",
  //       "awslogs-create-group": "true",
  //       "awslogs-stream-prefix": "mc"
  //   }
  // },

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
