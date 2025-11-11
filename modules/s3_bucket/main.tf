
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

resource "aws_s3_object" "script" {
  bucket = aws_s3_bucket.this.bucket
  key    = var.script_key
  source = var.script_source
  etag   = filemd5(var.script_source)
}
