resource "aws_dynamodb_table" "tawkify_kubeflow_tfstate_locks" {
  name         = "tawkify-kubeflow-tfstate-${var.env_name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
  point_in_time_recovery {
    enabled = true
  }
  server_side_encryption {
    enabled = true
  }
}

resource "aws_s3_bucket" "tawkify_kubeflow_tfstate_bucket" {
  bucket = "tawkify-kubeflow-tfstate-${var.env_name}"
  tags = {
    Name = "Tawkify Kubeflow ${var.env_name} TFState Bucket"
  }
}

# Note: ACLs are now by deafult disabled, and cannot be created unless the ownership settings are changed. See https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html
resource "aws_s3_bucket_public_access_block" "tawkify_kubeflow_tfstate_bucket_pab" {
  bucket = aws_s3_bucket.tawkify_kubeflow_tfstate_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tawkify_kubeflow_tfstate_bucket_versioning" {
  bucket = aws_s3_bucket.tawkify_kubeflow_tfstate_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tawkify_kubeflow_tfstate_bucket_enc" {
  bucket = aws_s3_bucket.tawkify_kubeflow_tfstate_bucket.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_role" "tawkify_dataeng_admin" {
  name = var.role_name
}
resource "aws_iam_role_policy_attachment" "tawkify_kubeflow_tfstate_policy_attach" {
  role       = data.aws_iam_role.tawkify_dataeng_admin.id
  policy_arn = resource.aws_iam_policy.tawkify_kubeflow_tfstate_policy.arn
}

resource "aws_iam_policy" "tawkify_kubeflow_tfstate_policy" {
  name        = "KubeflowTFStateBucketAccess${title(var.env_name)}"
  description = "Kubeflow TFStateBucket Access/Modify ${var.env_name}"
  policy      = data.aws_iam_policy_document.tawkify_kubeflow_tfstate_policy_document.json
}

data "aws_iam_policy_document" "tawkify_kubeflow_tfstate_policy_document" {
  statement {
    effect    = "Allow"
    resources = [aws_s3_bucket.tawkify_kubeflow_tfstate_bucket.arn]
    actions   = ["s3:ListBucket"]
    sid       = "BucketAccess"
  }
  statement {
    effect = "Allow"

    resources = [
      join("/", [aws_s3_bucket.tawkify_kubeflow_tfstate_bucket.arn, var.key])
    ]

    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    sid     = "StateObjectOperations"
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [aws_dynamodb_table.tawkify_kubeflow_tfstate_locks.arn]
    sid       = "LockTableOperations"
  }

}
