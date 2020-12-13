output "ebs_volume_id" {
  description = "EBS volume ID"
  value       = aws_ebs_volume.minecraft.id
}