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