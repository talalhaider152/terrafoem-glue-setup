region        = "sa-east-1"
role_name     = "glue-dev-role"
bucket_name   = "dev-glue-script-bucket-11022"
script_key    = "scripts/dev_glue_script.py"
script_source = "scripts/etl_job.py"
job_name      = "dev-glue-job"
max_capacity  = 2
timeout       = 30

github_oidc_role_name    = "github-actions-terraform-dev"
github_oidc_repositories = ["spectre/terrafoem-glue-setup"]
github_oidc_policy_arns  = ["arn:aws:iam::aws:policy/AdministratorAccess"]


