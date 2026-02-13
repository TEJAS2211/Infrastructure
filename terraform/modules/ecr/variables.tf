variable "repository_names" {
  type = list(string)
}

output "patient_service_repository_url" {
  value = data.aws_ecr_repository.services["patientservice"].repository_url
}

output "appointment_service_repository_url" {
  value = data.aws_ecr_repository.services["appointmentservice"].repository_url
}

output "frontend_repository_url" {
  value = data.aws_ecr_repository.services["patientportal"].repository_url
}

output "patient_portal_repository_url" {
  value = data.aws_ecr_repository.services["patientportal"].repository_url
}
