provider "aws" {}

terraform {
  backend "s3" {
    bucket = "koshuk-backup-terrafrom"
    key    = "lab_project/terraform.tfstate"
    region = "eu-north-1"
    dynamodb_table = "terraform_state_aws_eu_north_1"
  }
}
 