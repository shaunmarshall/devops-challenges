terraform {
  backend "s3" {
    bucket = "devops-challenge-terraform-tfstate-files"
    key    = "devoops-challenge-terraform.tfstate"
    region = "eu-west-1"
    encrypt = true
  }
}
