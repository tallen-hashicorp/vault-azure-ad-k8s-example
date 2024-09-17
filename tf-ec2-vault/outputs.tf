output "id" {
  description = "List of IDs of instances"
  value       = aws_instance.vault[*].id
}

output "public_dns" {
  description = "List of public DNS names assigned to the instances"
  value       = aws_instance.vault[*].public_dns
}

output "public_ip" {
  description = "List of public IP assigned to the instances"
  value       = aws_eip.this[*].public_ip
}