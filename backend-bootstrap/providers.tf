provider "aws" {
  # profile = "dataeng"
  allowed_account_ids = ["352587061287"] # data sandbox
  region              = "us-west-2"
  assume_role {
    role_arn = "arn:aws:iam::352587061287:role/Tawkify-dataeng-admin"
  }
  default_tags {
    tags = {
      Environment = var.env_name,
      Terraform   = true
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
