SHELL := /bin/bash # Use bash syntax

init:
	terraform init -var-file sandbox/terraform.tfvars

plan: 
	terraform plan -var-file sandbox/terraform.tfvars

apply: 
	terraform apply -var-file sandbox/terraform.tfvars

refresh: 
	terraform apply -var-file sandbox/terraform.tfvars -refresh-only

.PHONY: *