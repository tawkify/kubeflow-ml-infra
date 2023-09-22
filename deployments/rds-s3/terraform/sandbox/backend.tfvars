bucket         = "tawkify-kubeflow-tfstate-sandbox"
key            = "global/s3/terraform.tfstate"
region         = "us-west-2"
dynamodb_table = "tawkify-kubeflow-tfstate-sandbox"
encrypt        = true
role_arn       = "arn:aws:iam::352587061287:role/Tawkify-dataeng-admin"
profile        = "default"
