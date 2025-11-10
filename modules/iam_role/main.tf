
resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })

  lifecycle {
    # Prevent recreation if role already exists with different config
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "GlueJobPolicy"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.glue_policy.json
}

data "aws_iam_policy_document" "glue_policy" {
  statement {
    actions   = ["glue:*"]
    resources = ["*"]
  }
}
