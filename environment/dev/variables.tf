
variable "job_name" {
  description = "The name of the Glue job."
  type        = string
}

variable "iam_role_arn" {
  description = "The ARN of the IAM role used by the Glue job."
  type        = string
}

variable "script_location" {
  description = "S3 location of the Glue script to be executed."
  type        = string
}

variable "max_capacity" {
  description = "The number of DPUs for the Glue job."
  type        = number
}

variable "timeout" {
  description = "Timeout for the Glue job in minutes."
  type        = number
}
