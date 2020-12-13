terraform {
  backend "s3" {}
}

resource "aws_ebs_volume" "minecraft" {
  availability_zone = "ap-southeast-1a"
  size = 1
}