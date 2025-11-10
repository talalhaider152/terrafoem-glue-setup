
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "role_name" {
  description = "IAM role name for the Glue job to assume."
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name to store Glue scripts."
  type        = string
}

variable "script_key" {
  description = "Key in S3 bucket where the Glue script will be uploaded."
  type        = string
}

variable "script_source" {
  description = "Local path to the Glue script file to upload."
  type        = string
}

variable "job_name" {
  description = "Name of the Glue job."
  type        = string
}

variable "max_capacity" {
  description = "Number of DPUs for the Glue job."
  type        = number
}

variable "timeout" {
  description = "Timeout for the Glue job in minutes."
  type        = number
}
