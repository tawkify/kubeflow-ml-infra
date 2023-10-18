locals {
  oidc_url       = module.eks_blueprints.eks_oidc_issuer_url
  aws_account_id = data.aws_caller_identity.current.account_id
  profiles       = ["annette"] # for each new profile, add the profile name here and run apply
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kf_oidc_trust_policy_document" {
  for_each = toset(local.profiles)

  version = "2012-10-17"

  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${local.aws_account_id}:oidc-provider/${local.oidc_url}"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_url}:sub"
      values   = ["system:serviceaccount:${each.key}:default-editor"]
    }
  }
}

data "aws_iam_policy_document" "kf_s3_access_policy_document" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${module.kubeflow_components.s3_bucket_name}",
      "arn:aws:s3:::${module.kubeflow_components.s3_bucket_name}/*",
    ]
  }
}

resource "aws_iam_policy" "kf_s3_access_policy" {
  policy = data.aws_iam_policy_document.kf_s3_access_policy_document.json
  name   = "KubeflowS3AccessPolicy${title(var.env_name)}"
}

resource "aws_iam_role" "kf_oidc_assume_role" {
  for_each           = toset(local.profiles)
  name               = "KubeflowAssumeRole${title(var.env_name)}-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.kf_oidc_trust_policy_document[each.key].json
}

resource "aws_iam_role_policy_attachment" "kf_s3_access" {
  for_each   = toset(local.profiles)
  policy_arn = aws_iam_policy.kf_s3_access_policy.arn
  role       = aws_iam_role.kf_oidc_assume_role[each.key].id
}

data "aws_iam_policy_document" "kf_redshift_data_policy" {
  statement {
    sid    = "DataAPIPermissions"
    effect = "Allow"
    actions = [
      "redshift-data:BatchExecuteStatement",
      "redshift-data:ExecuteStatement",
      "redshift-data:CancelStatement",
      "redshift-data:ListStatements",
      "redshift-data:GetStatementResult",
      "redshift-data:DescribeStatement",
      "redshift-data:ListDatabases",
      "redshift-data:ListSchemas",
      "redshift-data:ListTables",
      "redshift-data:DescribeTable"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "SecretsManagerPermissions"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [data.terraform_remote_state.infra.outputs.kubeflow_redshift_user_secret]
  }
}

resource "aws_iam_policy" "kf_redshift_data_policy" {
  name   = "KubeflowRedshiftDataPolicy${title(var.env_name)}"
  policy = data.aws_iam_policy_document.kf_redshift_data_policy.json
}

resource "aws_iam_role_policy_attachment" "kf_redshift_data" {
  for_each   = toset(local.profiles)
  policy_arn = aws_iam_policy.kf_redshift_data_policy.arn
  role       = aws_iam_role.kf_oidc_assume_role[each.key].id
}
