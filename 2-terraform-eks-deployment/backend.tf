terraform {
  backend "s3" {
    bucket = "jenkins-app-kub-2026-v2"
    region = "us-east-2"
    key = "eks/terraform.tfstate"
  }
}
