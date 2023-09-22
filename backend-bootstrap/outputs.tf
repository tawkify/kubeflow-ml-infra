output "tfstate_bucket" {
  value = aws_s3_bucket.tawkify_kubeflow_tfstate_bucket.bucket

}
