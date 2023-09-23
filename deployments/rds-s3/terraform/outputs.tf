output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks_blueprints.eks_cluster_id
}

output "eks_managed_nodegroups" {
  description = "EKS managed node groups"
  value       = module.eks_blueprints.managed_node_groups
}

output "eks_managed_nodegroup_ids" {
  description = "EKS managed node group ids"
  value       = module.eks_blueprints.managed_node_groups_id
}

output "eks_managed_nodegroup_arns" {
  description = "EKS managed node group arns"
  value       = module.eks_blueprints.managed_node_group_arn
}

output "eks_managed_nodegroup_role_name" {
  description = "EKS managed node group role name"
  value       = module.eks_blueprints.managed_node_group_iam_role_names
}

output "eks_managed_nodegroup_status" {
  description = "EKS managed node group status"
  value       = module.eks_blueprints.managed_node_groups_status
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

output "region" {
  value       = local.region
  description = "AWS region"
}

output "rds_endpoint" {
  value       = module.kubeflow_components.rds_endpoint
  description = "The address of the RDS endpoint"
}

output "s3_bucket_name" {
  value       = module.kubeflow_components.s3_bucket_name
  description = "The name of the created S3 bucket"
}

output "kf_profile_role_arns" {
  value = {
    for profile in local.profiles: profile => aws_iam_role.kf_oidc_assume_role[profile].arn
  }
  description = "IAM Roles for Kubeflow profiles"
}