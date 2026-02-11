terraform {
  backend "s3" {
    bucket  = "hospital-management"
    key     = "stage/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}
