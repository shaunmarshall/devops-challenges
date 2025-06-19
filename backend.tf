terraform {
  backend "s3" {
    bucket = "devops-challenge-terraform-tfstate-files"
    key    = "${var.deployment_tag}-terraform.tfstate"
    region = "eu-west-1"
    encrypt = true
  }
}
