#!/bin/bash

# Variables
AWS_REGION="sa-east-1"  # Set your AWS region here
BUCKET_NAME="my-terraform-state-bucket-$(date +%s)"  # Create a unique bucket name with timestamp
DYNAMODB_TABLE_NAME="terraform-lock"
KEY_NAME="terraform.tfstate"

# Create the S3 bucket for Terraform state
echo "Creating S3 bucket for Terraform state..."
aws s3api create-bucket --bucket $BUCKET_NAME --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
if [ $? -ne 0 ]; then
  echo "Error creating S3 bucket. Exiting."
  exit 1
fi
echo "S3 bucket created: $BUCKET_NAME"

# Enable versioning on the S3 bucket for state management
echo "Enabling versioning on the S3 bucket..."
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
if [ $? -ne 0 ]; then
  echo "Error enabling versioning on S3 bucket. Exiting."
  exit 1
fi
echo "Versioning enabled for S3 bucket."

# Create the DynamoDB table for state locking
echo "Creating DynamoDB table for state locking..."
aws dynamodb create-table --table-name $DYNAMODB_TABLE_NAME \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $AWS_REGION
if [ $? -ne 0 ]; then
  echo "Error creating DynamoDB table. Exiting."
  exit 1
fi
echo "DynamoDB table created: $DYNAMODB_TABLE_NAME"

# Update backend.tf with the S3 and DynamoDB configuration
echo "Updating backend.tf..."

cat > backend.tf <<EOF
terraform {
  backend "s3" {
    bucket         = "$BUCKET_NAME"
    key            = "$KEY_NAME"
    region         = "$AWS_REGION"
    encrypt        = true
    dynamodb_table = "$DYNAMODB_TABLE_NAME"
  }
}
EOF

echo "backend.tf file has been updated."

# Initialize Terraform to configure the backend
echo "Initializing Terraform..."
terraform init
if [ $? -ne 0 ]; then
  echo "Error initializing Terraform. Exiting."
  exit 1
fi
echo "Terraform initialized successfully."

echo "Terraform backend setup is complete."
 