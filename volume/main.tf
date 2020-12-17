terraform {
  backend "s3" {}
}

resource "aws_ebs_volume" "minecraft" {
  availability_zone = var.aws_az
  size = 1
}