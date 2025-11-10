terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-1762804809"
    key            = "terraform.tfstate"
    region         = "sa-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}