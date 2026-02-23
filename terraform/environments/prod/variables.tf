variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "hospital-management"
}

# ---------------- VPC (MATCHES YOUR ACTUAL AWS VPC) ----------------
variable "existing_vpc_id" {
  description = "Use an existing VPC by specifying its ID"
  type        = string
  default     = "vpc-07e97883803762ed5"
}

# Public subnets (for ALB)
variable "public_subnet_ids" {
  description = "Public subnet IDs (ALB will be placed here)"
  type        = list(string)
  default     = [
    "subnet-09e87e6712a952ec5",
    "subnet-0249356070b523f11",
    "subnet-01b2494e2f4f1e52c"
  ]
}

# Private subnets (ECS + RDS will run here)
variable "private_subnet_ids" {
  description = "Private subnet IDs (ECS Fargate + RDS)"
  type        = list(string)
  default     = [
    "subnet-00929f9c61fa15541",
    "subnet-0a9f746f063b173f7",
    "subnet-03943aeccefecee34"
  ]
}

# (Kept for module compatibility even if using existing VPC)
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.180.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.180.128.0/20", "10.180.144.0/20", "10.180.160.0/20"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.180.0.0/20", "10.180.16.0/20", "10.180.32.0/20"]
}

# ---------------- ECS (ORIGINAL SCALE: 6 FARGATE TASKS) ----------------
variable "ecs_task_cpu" {
  description = "ECS task CPU"
  type        = string
  default     = "256"
}

variable "ecs_task_memory" {
  description = "ECS task memory"
  type        = string
  default     = "512"
}

# 3 services × 2 tasks = 6 Fargate tasks (as original architecture)
variable "ecs_service_desired_count" {
  description = "Desired number of ECS tasks per service"
  type        = number
  default     = 2
}

# ---------------- RDS (ORIGINAL PRODUCTION CONFIG) ----------------
variable "db_engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0.35"
}

# Original size (NOT free tier)
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.small"
}

# Original storage (100 GB)
variable "db_allocated_storage" {
  description = "RDS allocated storage (GB)"
  type        = number
  default     = 100
}

# Original backup retention
variable "db_backup_retention_period" {
  description = "RDS backup retention period (days)"
  type        = number
  default     = 30
}

# ---------------- MONITORING ----------------
variable "enable_monitoring" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

# ---------------- CRITICAL: ECS EXECUTION ROLE ----------------
variable "shared_execution_role_arn" {
  description = "Shared IAM role ARN used for ECS task execution and task role"
  type        = string
  default     = "arn:aws:iam::839690183795:role/ecsTaskExecutionRoleHospital"
}
