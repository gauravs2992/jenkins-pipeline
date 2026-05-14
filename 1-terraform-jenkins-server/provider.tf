terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  access_key = "AKIA5ABFMRLOXDCIKRVI"
  secret_key = "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"
}
