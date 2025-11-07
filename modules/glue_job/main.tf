
resource "aws_glue_job" "this" {
  name     = var.job_name
  role_arn = var.iam_role_arn
  command {
    name            = "glueetl"
    script_location = var.script_location
  }
  max_capacity = var.max_capacity
  timeout      = var.timeout
}
