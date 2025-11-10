region       = "sa-east-1"
role_name    = "glue-prod-role"
bucket_name  = "prod-glue-script-bucket"
script_key   = "scripts/prod_glue_script.py"
script_source = "scripts/prod_glue_script.py"
job_name     = "prod-glue-job"
max_capacity = 4
timeout      = 60


