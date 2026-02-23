terraform {
  backend "s3" {
    bucket  = "hospital-tf-state-839690183795"
    key     = "prod/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
