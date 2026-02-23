output "vpc_id" {
  value = module.networking.vpc_id
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "ecr_repositories" {
  value = {
    patient      = "839690183795.dkr.ecr.us-east-1.amazonaws.com/patient"
    appointment  = "839690183795.dkr.ecr.us-east-1.amazonaws.com/appointment"
    portal       = "839690183795.dkr.ecr.us-east-1.amazonaws.com/portal"
  }
}

output "shared_alb_dns" {
  value = module.networking.alb_dns_name
}
