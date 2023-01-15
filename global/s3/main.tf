provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "stage-up-and-running-state"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

# every update to a file in the bucket creates a new version of that file.
# This allows you to see older versions of the file and revert to those older versions at any time, which can be a useful fallback mechanism if something goes wrong:
resource "aws_s3_bucket_versioning" "versioning_enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# This ensures that your state files, and any secrets they might contain, are always encrypted on disk when stored in S3:
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to the S3 bucket
# S3 buckets are private by default
# Since your Terraform state files may contain sensitive data and secrets, 
# it’s worth adding this extra layer of protection to 
# ensure no one on your team can ever accidentally make this S3 bucket public
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table to use for locking
# It supports strongly consistent reads and conditional writes, 
# which are all the ingredients you need for a distributed lock system
# it’s completely managed, so you don’t have any infrastructure to run yourself, 
# and it’s inexpensive, with most Terraform usage easily fitting into the AWS Free Tier
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "stage-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket = "stage-up-and-running-state"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "stage-up-and-running-locks"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
  required_version = ">= 1.1.0"

}
