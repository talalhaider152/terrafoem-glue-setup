region        = "sa-east-1"
role_name     = "glue-prod-role"
bucket_name   = "prod-glue-script-bucket"
script_key    = "scripts/prod_glue_script.py"
script_source = "scripts/etl_job.py"
job_name      = "prod-glue-job"
max_capacity  = 4
timeout       = 60

github_oidc_role_name    = "github-actions-terraform-prod"
github_oidc_repositories = ["spectre/terrafoem-glue-setup"]
github_oidc_policy_arns  = ["arn:aws:iam::aws:policy/AdministratorAccess"]


