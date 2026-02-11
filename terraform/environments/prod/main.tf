# Networking Module
module "networking" {
  source = "../../modules/networking"

  environment          = var.environment
  app_name             = var.app_name
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
}

# ECR Repositories
module "ecr" {
  source = "../../modules/ecr"

  repository_names = [
    "patientservice",
    "appointmentservice",
    "patientportal"
  ]
}

# Secrets Manager
module "secrets" {
  source = "../../modules/secrets"

  environment = var.environment
  app_name    = var.app_name
}

# RDS MySQL Database
module "rds" {
  source = "../../modules/rds"

  environment            = var.environment
  app_name               = var.app_name
  db_subnet_group_name   = module.networking.db_subnet_group_name
  vpc_security_group_ids = [module.networking.rds_security_group_id]

  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  backup_retention_period = var.db_backup_retention_period

  depends_on = [module.secrets]
}

# ECS Cluster & Services
module "ecs_patient_service" {
  source = "../../modules/ecs"

  app_name       = var.app_name
  environment    = var.environment
  service_name   = "patient-service"
  container_port = 3001

  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  private_subnet_ids    = module.networking.private_subnet_ids
  alb_security_group_id = module.networking.alb_security_group_id
  ecs_security_group_id = module.networking.ecs_security_group_id

  ecr_repository_url = module.ecr.patient_service_repository_url
  task_cpu           = var.ecs_task_cpu
  task_memory        = var.ecs_task_memory
  desired_count      = var.ecs_service_desired_count

  depends_on = [aws_ecs_cluster.main, module.rds]
}

module "ecs_appointment_service" {
  source = "../../modules/ecs"

  app_name       = var.app_name
  environment    = var.environment
  service_name   = "appointment-service"
  container_port = 3002

  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  private_subnet_ids    = module.networking.private_subnet_ids
  alb_security_group_id = module.networking.alb_security_group_id
  ecs_security_group_id = module.networking.ecs_security_group_id

  ecr_repository_url = module.ecr.appointment_service_repository_url
  task_cpu           = var.ecs_task_cpu
  task_memory        = var.ecs_task_memory
  desired_count      = var.ecs_service_desired_count

  depends_on = [aws_ecs_cluster.main, module.rds]
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_monitoring ? "enabled" : "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 30
}
