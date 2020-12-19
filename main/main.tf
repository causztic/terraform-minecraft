terraform {
  backend "s3" {}
}
resource "cloudflare_record" "minecraft" {
  zone_id = var.cloudflare_zone_id
  name = "mc"
  value = aws_instance.web.public_ip
  type = "A"
  depends_on = [aws_instance.web]
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
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
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

  provisioner "file" {
    content     = templatefile("scripts/server.properties", local.server_properties)
    destination = "/tmp/server.properties"

    connection {
      user        = "ec2-user"
      private_key = file(var.ec2_private_key)
      host        = self.public_ip
    }
  }
  # provisioner "local-exec" {
  #   when    = destroy
  #   command = <<EOT
  #    curl -v \
  #     -H "Authorization: Bot ${var.discord_bot_token}" \
  #     -H "Content-Type: application/json" \
  #     -X POST \
  #     -d '{"content":"server down!"}' \
  #     https://discordapp.com/api/channels/${var.discord_channel_id}/messages"
  #   EOT
  # }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name  = var.device_name
  skip_destroy = true
  volume_id    = data.terraform_remote_state.volume.outputs.ebs_volume_id
  instance_id  = aws_instance.web.id
}

locals {
  server_properties = {
    motd = "A Minecraft Server"
    rcon_password = var.rcon_password
  }
  script_variables = {
    device_name = var.device_name
    min = var.min_memory
    max = var.max_memory
    discord_bot_token = var.discord_bot_token
    discord_channel_id = var.discord_channel_id
  }
}
