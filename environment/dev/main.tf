
module "iam_role" {
  source   = "../../modules/iam_role"
  role_name = "glue-dev-role"
}

module "s3_bucket" {
  source        = "../../modules/s3_bucket"
  bucket_name   = "dev-glue-script-bucket-11022"
  script_key    = "scripts/dev_glue_script.py"
  script_source = "../../scripts/dev_glue_script.py"

}

module "glue_job" {
  source         = "../../modules/glue_job"
  job_name       = "dev-glue-job"
  iam_role_arn   = module.iam_role.iam_role_arn
  script_location = "s3://${module.s3_bucket.bucket_name}/${module.s3_bucket.script_key}"
  max_capacity    = 2
  timeout         = 30
}
