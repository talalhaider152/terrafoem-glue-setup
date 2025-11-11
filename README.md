This Terraform project provisions AWS Glue infrastructure including IAM roles, S3 buckets, Glue jobs, and GitHub OIDC integration for CI/CD deployments.
## Terraform Version
### 1.6.6

## Architecture

The project creates the following AWS resources:

- **IAM Roles**: 
  - Glue job execution role
  - GitHub Actions OIDC role for Terraform deployments
- **S3 Bucket**: Stores Glue ETL scripts
- **AWS Glue Job**: ETL job configuration with script location and execution parameters
- **OIDC Provider**: GitHub Actions OIDC provider for secure authentication (shared across environments)


## Project Structure

```
.
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Root module variables
├── outputs.tf                 # Root module outputs
├── backend.tf                 # S3 backend configuration
├── env/
│   ├── dev/
│   │   └── dev.tfvars         # Development environment variables
│   └── prod/
│       └── prod.tfvars        # Production environment variables
├── modules/
│   ├── github_oidc_role/      # GitHub OIDC IAM role module
│   ├── iam_role/              # Glue IAM role module
│   ├── s3_bucket/             # S3 bucket and script upload module
│   └── glue_job/              # AWS Glue job module
└── scripts/
    └── etl_job.py             # Sample Glue ETL script
```

## Setup

### 1. Configure Backend

The project uses an S3 backend for state management. Please run the .sh file and then update `backend.tf` with your S3 bucket and DynamoDB table details:



### 2. Configure Environment Variables

#### Development Environment

Edit `env/dev/dev.tfvars` with your development settings:



#### Production Environment

Edit `env/prod/prod.tfvars` with your production settings. **Important**: If you've already created the OIDC provider in dev, you must specify the existing provider ARN:


> **Note**: The OIDC provider for GitHub Actions is created once per AWS account. When deploying to multiple environments (dev, prod), the first deployment creates the provider. Subsequent deployments should reference the existing provider ARN using `github_oidc_existing_provider_arn` to avoid "EntityAlreadyExists" errors.

## Usage

### Initialize Terraform

```bash
terraform init
```

### Plan Deployment

For development:
```bash
terraform plan -var-file="env/dev/dev.tfvars"
```

For production:
```bash
terraform plan -var-file="env/prod/prod.tfvars"
```

### Apply Configuration

For development:
```bash
terraform apply -var-file="env/dev/dev.tfvars"
```

For production:
```bash
terraform apply -var-file="env/prod/prod.tfvars"
```

### Destroy Resources

```bash
terraform destroy -var-file="env/dev/dev.tfvars"
```

## Important Notes

### OIDC Provider Management

The GitHub OIDC provider (`token.actions.githubusercontent.com`) is a global resource per AWS account. When deploying to multiple environments:

1. **First deployment (e.g., dev)**: The OIDC provider will be created automatically
2. **Subsequent deployments (e.g., prod)**: You must provide the existing provider ARN in your environment's .tfvars file (e.g., env/prod/prod.tfvars) using `github_oidc_existing_provider_arn`

To find your OIDC provider ARN:
- Check the Terraform outputs from the first deployment
- Or use AWS CLI: `aws iam list-open-id-connect-providers`
- Format: `arn:aws:iam::ACCOUNT-ID:oidc-provider/token.actions.githubusercontent.com`