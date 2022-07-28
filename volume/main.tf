terraform {
  backend "s3" {}
}

resource "aws_efs_file_system" "minecraft" {
  tags = {
    Name = "Minecraft"
  }
}