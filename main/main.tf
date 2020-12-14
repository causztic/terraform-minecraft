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
data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_configuration" "ecs_launch_config" {
  image_id        = data.aws_ami.ecs.id
  instance_type   = "t3.nano"
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier  = [aws_subnet.public.id]
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity = 1
  min_size         = 1
  max_size         = 1

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "minecraft" {
  name = "minecraft"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.asg.arn
  }
}

resource "aws_ecs_cluster" "minecraft" {
  name = "minecraft-cluster"
  default_capacity_provider_strategy {
    capacity_provider = "minecraft"
  }
}
resource "aws_ecs_service" "minecraft" {
  name            = "minecraft"
  cluster         = aws_ecs_cluster.minecraft.id
  task_definition = aws_ecs_task_definition.minecraft.arn
  desired_count   = 1

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [ap-southeast-1a, ap-southeast-1b, ap-southeast-1c]"
  }

  network_configuration {
    subnets = [aws_subnet.public.id]
    security_groups = [aws_security_group.minecraft.id]
  }
}

resource "aws_ecs_task_definition" "minecraft" {
  family                = "minecraft"
  container_definitions = file("task-definitions/service.json")
  requires_compatibilities = [ "EC2" ]
  network_mode             = "awsvpc"

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
}
