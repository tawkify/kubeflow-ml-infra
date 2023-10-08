SHELL := /bin/bash # Use bash syntax

setup:
	brew bundle install
	make init

init:
	terraform init -backend-config sandbox/backend.tfvars

plan: 
	terraform plan -var-file sandbox/terraform.tfvars

apply: 
	terraform apply -var-file sandbox/terraform.tfvars

refresh: 
	terraform apply -var-file sandbox/terraform.tfvars -refresh-only

config-eks:
	terraform output -raw configure_kubectl | bash

port-forward:
	$(eval IP_ADDRESS:=0.0.0.0)
	$(eval PORT:=8080)
	kubectl port-forward svc/istio-ingressgateway --address $(IP_ADDRESS) -n istio-system $(PORT):80

get-dex-config:
	kubectl get configmap dex -n auth -o jsonpath='{.data.config\.yaml}' > dex-yaml.yaml

add-dex-user-from-config:
	kubectl create configmap dex --from-file=config.yaml=dex-yaml.yaml -n auth --dry-run=client -o yaml | kubectl apply -f -
	rm dex-yaml.yaml

create-profile:
	kubectl apply -f profile_iam.yaml
	rm profile_iam.yaml
	kubectl rollout restart deployment dex -n auth

namespace-access-pipelines:
	kubectl apply -f kfp_sa_token.yaml
	rm kfp_sa_token.yaml

deploy: init \
 create-eks-cluster \
 deploy-eks-blueprints-k8s-addons \
 deploy-kubeflow-components

delete: delete-kubeflow-components \
 delete-eks-blueprints-k8s-addons \
 delete-eks-cluster 

create-eks-cluster:
	terraform apply -var-file sandbox/terraform.tfvars -target="module.eks_blueprints" -auto-approve
	make config-eks

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