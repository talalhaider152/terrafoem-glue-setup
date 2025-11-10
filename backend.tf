terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-1762804809" # Replace with your S3 bucket name
    key            = "prod&dev/terraform.tfstate" # Path within the S3 bucket
    region         = "sa-east-1"                     # AWS region of your S3 bucket
    dynamodb_table = "terraform-locks"    # Replace with your DynamoDB table name for locking
    encrypt        = true                            # Optional: Enable server-side encryption for the state file
  }
}