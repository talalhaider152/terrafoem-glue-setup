terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

}

provider "aws" {
  region = var.region
}

module "iam_role" {
  source    = "./modules/iam_role"
  role_name = var.role_name
}

module "s3_bucket" {
  source        = "./modules/s3_bucket"
  bucket_name   = var.bucket_name
  script_key    = var.script_key
  script_source = var.script_source
}

module "glue_job" {
  source          = "./modules/glue_job"
  job_name        = var.job_name
  iam_role_arn    = module.iam_role.iam_role_arn
  script_location = "s3://${module.s3_bucket.bucket_name}/${module.s3_bucket.script_key}"
  output_path     = "s3://${module.s3_bucket.bucket_name}/output/"
  max_capacity    = var.max_capacity
  timeout         = var.timeout
}

