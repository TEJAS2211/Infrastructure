terraform {
  backend "s3" {
    bucket  = "hospital-management"
    key     = "dev/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}
