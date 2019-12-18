# Docker image with Terraform, Terragrunt and all needed components to easily manage cloud infrastructure.

[![GitHub ChristophShyper/docker-terragrunt](https://img.shields.io/badge/github-ChristophShyper%2Fdocker--terragrunt-blue.svg)](https://github.com/christophshyper/docker-terragrunt "shields.io")
[![GitHub last commit](https://img.shields.io/github/last-commit/christophshyper/docker-terragrunt)](https://github.com/ChristophShyper/docker-terragrunt/commits/master "shields.io")
<br>
[![Actions Status](https://github.com/ChristophShyper/docker-terragrunt/workflows/On%20commit%20push/badge.svg)](https://github.com/ChristophShyper/docker-terragrunt/actions?query=workflow%3A%22On+commit+push%22 "github.com")
[![Actions Status](https://github.com/ChristophShyper/docker-terragrunt/workflows/On%20pull%20request/badge.svg)](https://github.com/ChristophShyper/docker-terragrunt/actions?query=workflow%3A%22On+pull+request%22 "github.com")
[![GitHub](https://img.shields.io/github/license/christophshyper/docker-terragrunt)](https://github.com/ChristophShyper/docker-terragrunt "shields.io")
<br>
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/christophshyper/docker-terragrunt "shields.io")
![GitHub repo size](https://img.shields.io/github/repo-size/christophshyper/docker-terragrunt "shields.io")
![GitHub language count](https://img.shields.io/github/languages/count/christophshyper/docker-terragrunt "shields.io")
![GitHub top language](https://img.shields.io/github/languages/top/christophshyper/docker-terragrunt "shields.io")
<br>
[![GitHub file size in bytes](https://img.shields.io/github/size/christophshyper/docker-terragrunt/Dockerfile?label=Dockerfile)](https://hub.docker.com/r/christophshyper/docker-terragrunt "shields.io")
[![Docker Pulls](https://img.shields.io/docker/pulls/christophshyper/docker-terragrunt)](https://hub.docker.com/r/christophshyper/docker-terragrunt "shields.io")
[![Docker Stars](https://img.shields.io/docker/stars/christophshyper/docker-terragrunt)](https://hub.docker.com/r/christophshyper/docker-terragrunt "shields.io")
[![MicroBadger Commit](https://images.microbadger.com/badges/commit/christophshyper/docker-terragrunt.svg)](https://microbadger.com/images/christophshyper/docker-terragrunt "Get your own commit badge on microbadger.com")
<br>
[![dockeri.co](https://dockeri.co/image/christophshyper/docker-terragrunt)](https://hub.docker.com/r/christophshyper/docker-terragrunt "dockeri.co")
<br>
[![MicroBadger Version](https://images.microbadger.com/badges/version/christophshyper/docker-terragrunt.svg)](https://microbadger.com/images/christophshyper/docker-terragrunt "Get your own version badge on microbadger.com")
[![MicroBadger Image](https://images.microbadger.com/badges/image/christophshyper/docker-terragrunt.svg)](https://microbadger.com/images/christophshyper/docker-terragrunt "Get your own image badge on microbadger.com")
**christophshyper/docker-terragrunt:latest**
<br>
[![MicroBadger Version](https://images.microbadger.com/badges/version/christophshyper/docker-terragrunt:aws-latest.svg)](https://microbadger.com/images/christophshyper/docker-terragrunt:aws-latest "Get your own version badge on microbadger.com")
[![MicroBadger Image](https://images.microbadger.com/badges/image/christophshyper/docker-terragrunt:aws-latest.svg)](https://microbadger.com/images/christophshyper/docker-terragrunt:aws-latest "Get your own image badge on microbadger.com")
**christophshyper/docker-terragrunt:aws-latest**

-----
**Docker image is available at [DockerHub](https://hub.docker.com/) under [christophshyper/docker-terragrunt](https://hub.docker.com/repository/docker/christophshyper/docker-terragrunt).**
<br>
Tag of Docker image tells which version of Terraform and Terragrunt it contains and which public cloud provider CLI it's bundled with or not (see below).
<br>
For example:
 * `christophshyper/docker-terragrunt:tf-0.12.18-tg-0.21.9` means it's Terraform v0.12.18 and Terragrunt v0.21.9 without additional CLI.
 * `christophshyper/docker-terragrunt:aws-tf-0.12.18-tg-0.21.9` means it's Terraform v0.12.18 and Terragrunt v0.21.9 with AWS CLI.

**Source code is available at [GitHub](https://github.com/) under [ChristophShyper/docker-terragrunt](https://github.com/ChristophShyper/docker-terragrunt) (will change soon to match DockerHub's value christophshyper).**

Dockerfile is based on two images made by [cytopia](https://github.com/cytopia): [docker-terragrunt](https://github.com/cytopia/docker-terragrunt/tree/1bc1a2c6de42c6d19f7e91f64f30256c24fd386f) and [docker-terragrunt-fmt](https://github.com/cytopia/docker-terragrunt-fmt/tree/3f8964bea0db043a05d4a8d622f94a07f109b5a7). 
<br>
Their original README files are included in this repository: [docker-terragrunt](https://github.com/ChristophShyper/docker-terragrunt/blob/master/README.docker-terragrunt.md) and [docker-terragrunt-fmt](https://github.com/ChristophShyper/docker-terragrunt/blob/master/README.docker-terragrunt-fmt.md).
<br>
Some changes have been applied to add more software to the image - list below.

-----
# Available flavours
**Please note focus of those images is to maintain availability of cutting edge versions of Terraform and Terragrunt, not CLIs or other dependencies.**
<br>
Hence, images are updated when new version of Terraform or Terragrunt is released. 
<br>
Furthermore, versioning labels of images contain versions of said software to emphasize it. See below.

### Summary
Docker image | Terraform version | Terragrunt version | Additional software
:--- | :--- | :--- | :--- 
`christophshyper/docker-terragrunt:latest`<br>`christophshyper/docker-terragrunt:tf-0.12.18-tg-0.21.9` |  v0.12.18 | v0.21.9 | N/A
`christophshyper/docker-terragrunt:aws-latest`<br>`christophshyper/docker-terragrunt:aws-tf-0.12.18-tg-0.21.9` |  v0.12.18 | v0.21.9 | [awscli](https://github.com/aws/aws-cli) - For interacting with AWS infrastructure, e.g. for publishing Lambda packages to S3.<br>[boto3](https://github.com/boto/boto3) - Python library for interacting with AWS infrastructure in scripts.

### Without public cloud provider CLIs
Use for example `christophshyper/docker-terragrunt:latest`.

### Amazon Web Services
Use for example `christophshyper/docker-terragrunt:aws-latest`.
<br>
Contains additionally:
* [awscli](https://github.com/aws/aws-cli) - For interacting with AWS infrastructure, e.g. for publishing Lambda packages to S3.
* [boto3](https://github.com/boto/boto3) - Python library for interacting with AWS infrastructure in scripts.

### Google Cloud Platform - TO BE ADDED SOON
~~Use for example `christophshyper/docker-terragrunt:aws-latest`.~~

### Microsoft Azure - TO BE ADDED SOON
~~Use for example `christophshyper/docker-terragrunt:azure-latest`.~~

-----
# Usage
Mount working directory under `/data` and run any deployment action, script or check.
<br>
Don't forget to pass cloud provider's credentials as additional file or environment variables. 

For example:
```bash
# Format all HCL files in current directory.
docker run --rm \ 
    -u $(id -u):$(id -g) \
    -v $(pwd):/data \
    -w /data \
    christophshyper/docker-terragrunt format.hcl

# Plan terraform deployment in current directory
docker run --rm \
    -ti \
    -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    -e AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
    -u $(id -u):$(id -g) \
    -v $(pwd):/data \
    -w /data/infra \
    christophshyper/docker-terragrunt:aws-latest terraform plan

# Apply terragrunt deployment in subdirectory
docker run --rm \
    -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    -e AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
    -u $(id -u):$(id -g) \
    -v $(pwd):/data \
    -w /data \
    christophshyper/docker-terragrunt:aws-latest terragrunt apply --terragrunt-working-dir infra/some/module
```

-----
# Additional software available in all images
### Scripts
Script name | Is included in PATH | Purpose | Source/Documentation
:--- | :---: | :--- | :---
`format-hcl.sh` | Yes | For formatting all HCL files (`.hcl`, `.tf` and `.tfvars`) into format suggested by [Hashicorp](https://github.com/hashicorp/hcl). |  [ChristophShyper](https://github.com/ChristophShyper/docker-terragrunt/blob/master/fmt/format-hcl.sh)
`/terragrunt-fmt.sh` | No | Dependency for `format-hcl.sh` | [cytopia](https://github.com/cytopia/docker-terragrunt-fmt/blob/master/data/terragrunt-fmt.sh) 

### Binaries and Python libraries
Name | Type | Purpose | Source/Documentation
:---: | :---: | :--- | :---
bash | Binary | For color output from `terraform` and`terragrunt`. Assures also access to some builtins.| https://www.gnu.org/software/bash/
curl | Binary | For interacting with [ElasticSearch](https://github.com/elastic/elasticsearch) and [Kibana](https://github.com/elastic/kibana).| https://curl.haxx.se/
docker | Binary | For running another container, e.g. for deploying Lambdas with [LambCI's](https://github.com/lambci) [docker-lambda](https://github.com/lambci/docker-lambda). | https://github.com/docker/docker-ce
git | Binary | For interacting with [Github](https://github.com) repositories. | https://git-scm.com/
jq | Binary | For parsing JSON outputs of [awscli](https://github.com/aws/aws-cli). | https://stedolan.github.io/jq/
make | Binary | For using `Makefile` instead of scripts in deployment process. | https://www.gnu.org/software/make/
openssl | Binary | For calculating BASE64SHA256 hash of Lambda packages. Assures updating Lambdas only when package hash changed. | https://github.com/openssl/openssl
ply | Python library | Dependency for [pyhcl](https://github.com/virtuald/pyhcl). | https://github.com/dabeaz/ply
pyhcl | Python library | For easily parsing of any files in HCL format, whether it's `.hcl`, `.tfvars` or `.tf`. | https://github.com/virtuald/pyhcl
python3 | Binary | For running more complex scripts during deployment process. | https://www.python.org/
scenery | Binary | For better coloring and visualization of `terraform plan` outputs. | https://github.com/dmlittle/scenery
terraform | Binary | For managing IaC. Dependency for [Terragrunt](https://github.com/gruntwork-io/terragrunt). | https://github.com/hashicorp/terraform 
terragrunt | Binary | For managing IaC. Wrapper over [Terraform](https://github.com/hashicorp/terraform). | https://github.com/gruntwork-io/terragrunt
zip | Binary |  For creating packages for Lambdas. | http://infozip.sourceforge.net/
