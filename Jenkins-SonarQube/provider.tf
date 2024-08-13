provider "aws" {
  region = "us-east-1" # Set your AWS region
  access_key = var.aws_access_key #Create Credentials.tf file or use Terraform vault to store credentials
  secret_key = var.aws_secret_key #Create Credentials.tf file or use Terraform vault to store credentials
}