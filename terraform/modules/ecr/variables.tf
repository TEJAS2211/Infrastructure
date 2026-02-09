variable "repository_names" {
  type = list(string)
}

output "patient_service_repository_url" {
  value = aws_ecr_repository.services["patient-service"].repository_url
}

output "appointment_service_repository_url" {
  value = aws_ecr_repository.services["appointment-service"].repository_url
}

output "frontend_repository_url" {
  value = aws_ecr_repository.services["frontend"].repository_url
}
