##############################################################################################
# Provider
##############################################################################################

provider "aws" {
  region              = var.providers_region
  allowed_account_ids = [var.aws_account_id]
}

provider "random" {}

terraform {
  backend "s3" {
    bucket = "712487951696-githubaction-bucket-state-file"
    key    = "iac-github-actions.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6"
    }
  }
}

##########################################################################################################
# BUCKET S3 Provider
##########################################################################################################
## Provider us-east-1
provider "aws" {
  region = "us-east-1"
  alias = "primary"
}

## Provider us-west-1
provider "aws" {
  region = "us-west-1"
  alias = "secondary"
}