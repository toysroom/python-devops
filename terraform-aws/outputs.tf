output "vm_public_ip" {
  description = "L'indirizzo IP pubblico della VM Jenkins"
  value       = aws_eip.jenkins_ip.public_ip
}

output "ecr_repository_url" {
  description = "L'URL del repository ECR"
  value       = aws_ecr_repository.ecr.repository_url
}