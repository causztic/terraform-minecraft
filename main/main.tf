terraform {
  backend "s3" {}
}

module "cloudflare" {
  source = "git::git@github.com:terrajungles/cloudflare.git"

  cloudflare_api_token = var.cloudflare_api_token
  subdomain            = "mc"
  ip_address           = aws_instance.web.public_ip
  zone_id              = var.cloudflare_zone_id
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
data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami*"]
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
resource "aws_key_pair" "admin" {
  key_name   = "minecraft-admin-key"
  public_key = file(var.ec2_public_key)
}
resource "aws_instance" "web" {
  ami                         = data.aws_ami.ami.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.minecraft.id]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  availability_zone           = var.aws_az
  key_name                    = aws_key_pair.admin.key_name

  tags = {
    Name = "minecraft"
  }

  user_data = templatefile("scripts/startup.sh", local.script_variables)
  depends_on = [aws_internet_gateway.gateway]
}

resource "aws_volume_attachment" "ebs_att" {
  device_name  = var.device_name
  skip_destroy = true
  volume_id    = data.terraform_remote_state.volume.outputs.ebs_volume_id
  instance_id  = aws_instance.web.id
}

locals {
  script_variables = {
    device_name = var.device_name
    min = var.min_memory
    max = var.max_memory
  }
}
