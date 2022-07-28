output "efs_volume_id" {
  description = "EFS volume ID"
  value       = aws_efs_file_system.minecraft.id
}