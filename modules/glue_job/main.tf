
resource "aws_glue_job" "this" {
  name     = var.job_name
  role_arn = var.iam_role_arn
  command {
    name            = "glueetl"
    script_location = var.script_location
  }
  glue_version = "5.0"
  default_arguments = {
    "--OUTPUT_PATH" = var.output_path
  }
  max_capacity = var.max_capacity
  timeout      = var.timeout
}
