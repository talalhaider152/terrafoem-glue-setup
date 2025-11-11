This Terraform project provisions AWS Glue infrastructure including IAM roles, S3 buckets, Glue jobs, and GitHub OIDC integration for CI/CD deployments.

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

The project uses an S3 backend for state management Update `backend.tf` with your S3 bucket and DynamoDB table details:



### 2. Configure Environment Variables

#### Development Environment

Edit `env/dev/dev.tfvars` with your development settings:

```hcl
region        = "sa-east-1"
role_name     = "glue-dev-role"
bucket_name   = "dev-glue-script-bucket"
script_key    = "scripts/dev_glue_script.py"
script_source = "scripts/etl_job.py"
job_name      = "dev-glue-job"
max_capacity  = 2
timeout       = 30

github_oidc_role_name    = "github-actions-terraform-dev"
github_oidc_repositories = ["your-org/your-repo"]
github_oidc_policy_arns  = ["arn:aws:iam::aws:policy/AdministratorAccess"]
```

#### Production Environment

Edit `env/prod/prod.tfvars` with your production settings. **Important**: If you've already created the OIDC provider in dev, you must specify the existing provider ARN:

```hcl
region        = "sa-east-1"
role_name     = "glue-prod-role"
bucket_name   = "prod-glue-script-bucket"
script_key    = "scripts/prod_glue_script.py"
script_source = "scripts/etl_job.py"
job_name      = "prod-glue-job"
max_capacity  = 4
timeout       = 60

github_oidc_role_name    = "github-actions-terraform-prod"
github_oidc_repositories = ["your-org/your-repo"]
github_oidc_policy_arns  = ["arn:aws:iam::aws:policy/AdministratorAccess"]
github_oidc_existing_provider_arn = "arn:aws:iam::ACCOUNT-ID:oidc-provider/token.actions.githubusercontent.com"
```

> **Note**: The OIDC provider for GitHub Actions is created once per AWS account. When deploying to multiple environments (dev, prod), the first deployment creates the provider. Subsequent deployments should reference the existing provider ARN using `github_oidc_existing_provider_arn` to avoid "EntityAlreadyExists" errors.

## Usage

### Initialize Terraform

```bash
terraform init
```

### Plan Deployment

For development:
```bash
terraform plan -var-file=env/dev/dev.tfvars
```

For production:
```bash
terraform plan -var-file=env/prod/prod.tfvars
```

### Apply Configuration

For development:
```bash
terraform apply -var-file=env/dev/dev.tfvars
```

For production:
```bash
terraform apply -var-file=env/prod/prod.tfvars
```

### Destroy Resources

```bash
terraform destroy -var-file=env/dev/dev.tfvars
```

## Modules

### github_oidc_role

Creates an IAM OIDC provider for GitHub Actions and an IAM role that can be assumed by GitHub Actions workflows.

**Features:**
- Creates or reuses existing OIDC provider
- Configurable repository access
- Supports multiple managed policy attachments

**Key Variables:**
- `role_name`: Name of the IAM role
- `repositories`: List of GitHub repositories (owner/name)
- `audience`: OIDC token audience (default: "sts.amazonaws.com")
- `thumbprints`: OIDC provider thumbprints
- `policy_arns`: Managed policy ARNs to attach
- `existing_oidc_provider_arn`: ARN of existing OIDC provider (optional)

### iam_role

Creates an IAM role for AWS Glue job execution.

### s3_bucket

Creates an S3 bucket and uploads the Glue ETL script.

**Features:**
- Automatic script upload with MD5 checksum
- Configurable bucket name and script key

### glue_job

Creates an AWS Glue ETL job.

**Features:**
- Configurable DPU capacity
- Timeout settings
- Custom output path configuration

## Variables

### Required Variables

- `region`: AWS region
- `role_name`: IAM role name for Glue job
- `bucket_name`: S3 bucket name for Glue scripts
- `script_key`: S3 key for the Glue script
- `script_source`: Local path to the Glue script file
- `job_name`: Name of the Glue job
- `max_capacity`: Number of DPUs for the Glue job
- `timeout`: Job timeout in minutes
- `github_oidc_role_name`: IAM role name for GitHub Actions
- `github_oidc_repositories`: List of GitHub repositories

### Optional Variables

- `github_oidc_policy_arns`: Managed policy ARNs (default: [])
- `github_oidc_audience`: OIDC token audience (default: "sts.amazonaws.com")
- `github_oidc_thumbprints`: OIDC provider thumbprints
- `github_oidc_existing_provider_arn`: Existing OIDC provider ARN (for multi-environment setups)

## Outputs

- `glue_job_arn`: ARN of the Glue job
- `glue_job_name`: Name of the Glue job
- `s3_bucket_name`: Name of the S3 bucket
- `iam_role_arn`: ARN of the Glue IAM role
- `github_oidc_role_arn`: ARN of the GitHub Actions IAM role
- `github_oidc_provider_arn`: ARN of the GitHub OIDC provider

## Important Notes

### OIDC Provider Management

The GitHub OIDC provider (`token.actions.githubusercontent.com`) is a global resource per AWS account. When deploying to multiple environments:

1. **First deployment (e.g., dev)**: The OIDC provider will be created automatically
2. **Subsequent deployments (e.g., prod)**: You must provide the existing provider ARN in your environment's .tfvars file (e.g., env/prod/prod.tfvars) using `github_oidc_existing_provider_arn`

To find your OIDC provider ARN:
- Check the Terraform outputs from the first deployment
- Or use AWS CLI: `aws iam list-open-id-connect-providers`
- Format: `arn:aws:iam::ACCOUNT-ID:oidc-provider/token.actions.githubusercontent.com`

### GitHub Actions Integration

This setup enables GitHub Actions to deploy Terraform infrastructure using OIDC authentication. Ensure your GitHub Actions workflow includes:

```yaml
permissions:
  id-token: write
  contents: read

- uses: aws-actions/configure-aws-credentials@v2
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: sa-east-1
```

## Troubleshooting

### Error: EntityAlreadyExists for OIDC Provider

If you encounter this error, it means the OIDC provider already exists. Solution:
1. Find the existing provider ARN (see above)
2. Add `github_oidc_existing_provider_arn` to your environment's .tfvars file (e.g., env/prod/prod.tfvars)
3. Re-run `terraform plan` and `terraform apply`

### S3 Bucket Name Conflicts

S3 bucket names must be globally unique. If you get a bucket name conflict, change the `bucket_name` in your environment's .tfvars file (e.g., env/prod/prod.tfvars).

## License

This project is provided as-is for educational and development purposes.
