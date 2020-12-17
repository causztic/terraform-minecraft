output "ip" {
  description = "Server public IP"
  value       = aws_instance.web.public_ip
}