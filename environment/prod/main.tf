
module "iam_role" {
  source   = "../../modules/iam_role"
  role_name = "glue-prod-role"
}

module "s3_bucket" {
  source        = "../../modules/s3_bucket"
  bucket_name   = "prod-glue-script-bucket"
  script_key    = "scripts/prod_glue_script.py"
  script_source = "../../scripts/prod_glue_script.py"

}

module "glue_job" {
  source         = "../../modules/glue_job"
  job_name       = "prod-glue-job"
  iam_role_arn   = module.iam_role.iam_role_arn
  script_location = "s3://${module.s3_bucket.bucket_name}/${module.s3_bucket.script_key}"
  max_capacity    = 4
  timeout         = 60
}
