#!/usr/bin/env bash

# Formats all HCL-format files under working directory
# Runs `terraform fmt` for all .tf files
# Run `/terraform-fmt.sh` for all .hcl files

/terraform-fmt.sh -recursive -write=true
terraform fmt -recursive -write=true
