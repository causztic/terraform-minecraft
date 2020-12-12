output "ipv4 address" {
  description = "IPv4 Address of server"
  value       = digitalocean_droplet.mc-server.ipv4_address
}