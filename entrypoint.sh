#!/bin/sh

if command -v aws > /dev/null; then
  aws --version ; echo
fi

if command -v az > /dev/null; then
  az version --output table ; echo
fi

if command -v gcloud > /dev/null; then
  gcloud --version ; echo
fi

if command -v terraform > /dev/null; then
  terraform --version ; echo
fi

if command -v tofu > /dev/null; then
  tofu --version ; echo
fi

terragrunt --version ; echo
