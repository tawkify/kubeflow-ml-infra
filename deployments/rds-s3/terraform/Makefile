SHELL := /bin/bash # Use bash syntax

init:
	terraform init -backend-config sandbox/backend.tfvars

plan: 
	terraform plan -var-file sandbox/terraform.tfvars

apply: 
	terraform apply -var-file sandbox/terraform.tfvars

deploy: init \
 create-eks-cluster \
 deploy-eks-blueprints-k8s-addons \
 deploy-kubeflow-components

delete: delete-kubeflow-components \
 delete-eks-blueprints-k8s-addons \
 delete-eks-cluster 

create-eks-cluster:
	terraform apply -var-file sandbox/terraform.tfvars -target="module.eks_blueprints" -auto-approve
	terraform output -raw configure_kubectl | bash

deploy-eks-blueprints-k8s-addons:
	terraform apply -var-file sandbox/terraform.tfvars -target="module.eks_blueprints_kubernetes_addons" -auto-approve

deploy-kubeflow-components:
	terraform apply -var-file sandbox/terraform.tfvars -target="module.kubeflow_components" -auto-approve

delete-eks-cluster:
	terraform destroy -var-file sandbox/terraform.tfvars -target="module.eks_blueprints" -auto-approve

delete-eks-blueprints-k8s-addons:
	terraform destroy -var-file sandbox/terraform.tfvars -target="module.eks_blueprints_kubernetes_addons" -auto-approve

delete-kubeflow-components:
	terraform destroy -var-file sandbox/terraform.tfvars -target="module.kubeflow_components" -auto-approve

# don't create executables
.PHONY: *