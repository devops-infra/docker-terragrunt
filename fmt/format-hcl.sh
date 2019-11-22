#!/usr/bin/env bash

# Formats all HCL-format files under working directory
# Runs `terraform fmt` for all .tf files
# Run `/terragrunt-fmt.sh` for all .hcl files

echo -e "\n=> Searching for .hcl files"
/terragrunt-fmt.sh -recursive -write=true

echo -e "\n=> Searching for .tf and .tfvars files"
terraform fmt -recursive -write=true
