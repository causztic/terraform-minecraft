output "ebs_volume_id" {
  description = "EBS volume id"
  value       = aws_ebs_volume.minecraft.id
}

output "ebs_arn" {
  description = "EBS ARN"
  value       = aws_ebs_volume.minecraft.arn
}