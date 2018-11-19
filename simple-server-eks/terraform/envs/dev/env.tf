# Dev environment.
# NOTE: If environment copied, change environment related values (e.g. "dev" -> "perf").

##### Terraform configuration #####

# Usage:
# AWS_PROFILE=tmv-test terraform init (only first time)
# AWS_PROFILE=tmv-test terraform get
# AWS_PROFILE=tmv-test terraform plan
# AWS_PROFILE=tmv-test terraform apply

# NOTE: You have to create backend S3 bucket and DynamoDB with LockID primary manually before creating new env!
terraform {
  required_version = ">=0.11.10"
  backend "s3" {
    bucket     = "marttkar-sseks-dev-terraform-backend" # NOTE: S3 is regional: always add the same identifying prefix to your S3 buckets!
    key        = "terraform.tfstate"
    region     = "eu-west-1"
    dynamodb_table = "marttkar-sseks-dev-terraform-backend-table" # NOTE: You have to create this DynamoDB manually with LockID primary key.
    profile    = "tmv-test"  # NOTE: This is AWS account profile, not env! You probably have two accounts: one dev (or test) and one prod.
  }
}

provider "aws" {
  region = "eu-west-1"
}
