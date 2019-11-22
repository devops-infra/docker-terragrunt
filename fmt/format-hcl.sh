#!/usr/bin/env bash

# Formats all HCL-format files under working directory
# Runs `terraform fmt` for all .tf files
# Run `/terragrunt-fmt.sh` for all .hcl files

/terragrunt-fmt.sh -recursive -write=true
terraform fmt -recursive -write=true
