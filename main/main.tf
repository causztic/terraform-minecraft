terraform {
  backend "s3" {}
}

resource "digitalocean_ssh_key" "default" {
  name       = "mc-server-ssh-key"
  public_key = file(var.do_public_key_dir)
}

resource "digitalocean_tag" "mc" {
   name = "minecraft"
}

# resource "digitalocean_droplet" "mc-server" {
#   depends_on         = [digitalocean_tag.mc]
#   image              = "docker-18-04"
#   name               = "mc-server"
#   tags               = [digitalocean_tag.mc.id]
#   ipv6               = false
#   region             = var.region
#   size               = var.size
#   private_networking = true
#   ssh_keys           = [digitalocean_ssh_key.default.fingerprint]
# }
