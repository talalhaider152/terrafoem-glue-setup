
variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
  default     = "dev-glue-script-bucket-012054648"
}

variable "script_key" {
  description = "The key in the S3 bucket for the Glue script."
  type        = string
}

variable "script_source" {
  description = "The local path to the Glue script."
  type        = string
}
