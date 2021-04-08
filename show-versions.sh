#!/bin/sh

if command -v aws &> /dev/null; then
  aws --version ; echo
fi

if command -v az &> /dev/null; then
  az version --output table ; echo
fi

if command -v gcloud &> /dev/null; then
  gcloud --version ; echo
fi

terraform --version ; echo
terragrunt --version ; echo
python3 --version
pip freeze ; echo
bash --version ; echo
curl --version ; echo
docker --version ; echo
hub --version ; echo
jq --version ; echo
echo hcledit `hcledit version` ; echo
make --version ; echo
ssh -V ; echo
openssl version ; echo
sops --version ; echo
tflint --version ; echo
zip --version ; echo
