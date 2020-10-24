# IaaC dockerized framework for Terraform and Terragrunt

Docker image with Terraform, Terragrunt, Python, Make, Docker, Git, and all needed components to easily manage cloud infrastructure.

**Docker image is available at [DockerHub](https://hub.docker.com/) under [devopsinfra/docker-terragrunt](https://hub.docker.com/repository/docker/devopsinfra/docker-terragrunt).**
<br>
Tag of Docker image tells which version of Terraform and Terragrunt it contains and which public cloud provider CLI it's bundled with or not (see below).
<br>
For example:
 * `devopsinfra/docker-terragrunt:tf-0.13.5-tg-0.25.5` means it's Terraform v0.13.5 and Terragrunt v0.25.5 without additional CLI.
 * `devopsinfra/docker-terragrunt:aws-tf-0.13.5-tg-0.25.5` means it's Terraform v0.13.5 and Terragrunt v0.25.5 with AWS CLI.

**Source code is available at [devopsinfra/docker-terragrunt](https://github.com/devopsinfra/docker-terragrunt).**

Dockerfile is based on two images made by [cytopia](https://github.com/cytopia): [docker-terragrunt](https://github.com/cytopia/docker-terragrunt/tree/1bc1a2c6de42c6d19f7e91f64f30256c24fd386f) and [docker-terragrunt-fmt](https://github.com/cytopia/docker-terragrunt-fmt/tree/3f8964bea0db043a05d4a8d622f94a07f109b5a7).
<br>
Original README files are included in this repository: [docker-terragrunt](https://github.com/devopsinfra/docker-terragrunt/blob/master/README.docker-terragrunt.md) and [docker-terragrunt-fmt](https://github.com/devopsinfra/docker-terragrunt/blob/master/README.docker-terragrunt-fmt.md).

This project grew much bigger than the original ones and is intended to be a framework for cloud Infrastructure-as-a-Code. 


## Badge swag
[
![GitHub](https://img.shields.io/badge/github-devops--infra%2Fdocker--terragrunt-brightgreen.svg?style=flat-square&logo=github)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/devops-infra/docker-terragrunt?color=brightgreen&label=Code%20size&style=flat-square&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/devops-infra/docker-terragrunt?color=brightgreen&label=Last%20commit&style=flat-square&logo=github)
](https://github.com/devops-infra/docker-terragrunt "shields.io")
[![Push to master](https://img.shields.io/github/workflow/status/devops-infra/docker-terragrunt/Push%20to%20master?color=brightgreen&label=Master%20branch&logo=github&style=flat-square)
](https://github.com/devops-infra/docker-terragrunt/actions?query=workflow%3A%22Push+to+master%22)
[![Push to other](https://img.shields.io/github/workflow/status/devops-infra/docker-terragrunt/Push%20to%20other?color=brightgreen&label=Pull%20requests&logo=github&style=flat-square)
](https://github.com/devops-infra/docker-terragrunt/actions?query=workflow%3A%22Push+to+other%22)
<br>
[
![DockerHub](https://img.shields.io/badge/docker-devopsinfra%2Fdocker--terragrunt-blue.svg?style=flat-square&logo=docker)
![Dockerfile size](https://img.shields.io/github/size/devops-infra/docker-terragrunt/Dockerfile?label=Dockerfile%20size&style=flat-square&logo=docker)
![Docker Pulls](https://img.shields.io/docker/pulls/devopsinfra/docker-terragrunt?color=blue&label=Pulls&logo=docker&style=flat-square)
](https://hub.docker.com/r/devopsinfra/docker-terragrunt "shields.io")
<br>
[
![DockerHub](https://img.shields.io/badge/docker-devopsinfra%2Fdocker--terragrunt:latest-blue.svg?style=flat-square&logo=docker)
![Docker version](https://img.shields.io/docker/v/devopsinfra/docker-terragrunt/latest?color=blue&label=Version&logo=docker&style=flat-square)
![Image size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/latest?label=Image%20size&style=flat-square&logo=docker)
](https://hub.docker.com/r/devopsinfra/docker-terragrunt "shields.io")
<br>
[
![DockerHub](https://img.shields.io/badge/docker-devopsinfra%2Fdocker--terragrunt:aws--latest-blue.svg?style=flat-square&logo=docker)
![Docker version](https://img.shields.io/docker/v/devopsinfra/docker-terragrunt/aws-latest?color=blue&label=Version&logo=docker&style=flat-square)
![Image size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/aws-latest?label=Image%20size&style=flat-square&logo=docker)
](https://hub.docker.com/r/devopsinfra/docker-terragrunt "shields.io")
<!-- ![Docker Pulls](https://img.shields.io/docker/pulls/devopsinfra/docker-terragrunt/aws-latest?color=blue&label=Pulls&logo=docker&style=flat-square) -->


# Summary
**Please note focus of those images is to maintain availability of cutting edge versions of Terraform and Terragrunt, not CLIs or other dependencies.**
<br>
Hence, images are updated when new version of Terraform or Terragrunt is released.
<br>
Furthermore, versioning labels of images contain versions of said software to emphasize it. See below.


### Available flavours

| Image name                                                                                            | Terraform version | Terragrunt version | Cloud API/SDK                                                                                                                                                                                                                                 |
| ----------------------------------------------------------------------------------------------------- | ----------------- | ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `devopsinfra/docker-terragrunt:latest`<br>`devopsinfra/docker-terragrunt:tf-0.13.5-tg-0.25.5`         | v0.13.5           | v0.25.5            | N/A                                                                                                                                                                                                                                           |
| `devopsinfra/docker-terragrunt:aws-latest`<br>`devopsinfra/docker-terragrunt:aws-tf-0.13.5-tg-0.25.5` | v0.13.5           | v0.25.5            | [awscli](https://github.com/aws/aws-cli) - For interacting with AWS infrastructure, e.g. for publishing Lambda packages to S3.<br>[boto3](https://github.com/boto/boto3) - Python library for interacting with AWS infrastructure in scripts. |

**Without public cloud provider CLIs**<br>
Use for example `devopsinfra/docker-terragrunt:latest`.

**Amazon Web Services**<br>
Use for example `devopsinfra/docker-terragrunt:aws-latest`.

_Google Cloud Platform - TO BE ADDED_<br>
~~Use for example `devopsinfra/docker-terragrunt:gcp-latest`.~~

_Microsoft Azure - TO BE ADDED_<br>
~~Use for example `devopsinfra/docker-terragrunt:azure-latest`.~~


# Usage
* Mount working directory under `/data`, e.g. `--volume $(pwd):/data`.
* Pass cloud provider's credentials as additional file or environment variables, e.g. `--env AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}` or `--volume ~/.aws/credentials:/root/.aws/credentials`.
* Run different Docker container inside this one by sharing the socket, e.g. `--volume /var/run/docker.sock:/var/run/docker.sock`.
* Access private GitHub repos by SSH (`git::git@github.com:my/private-repo.git`) by sharing private key, e.g. `--volume ~/.ssh/id_rsa_github_key:/root/.ssh/id_rsa`.

For example:
```bash
# Format all HCL files in current directory. Including subdirectories.
docker run --rm \
    --user $(id -u):$(id -g) \
    --volume $(pwd):/data \
    devopsinfra/docker-terragrunt:latest format-hcl

# Plan terraform deployment in AWS for files in current directory.
docker run --rm \
    --tty --interactive \
    --env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
    --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    --env AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
    --user $(id -u):$(id -g) \
    --volume $(pwd):/data \
    devopsinfra/docker-terragrunt:aws-latest terraform plan

# Apply terragrunt deployment in subdirectory. With SSH access to GitHub using a private key.
docker run --rm \
    --tty --interactive \
    --user $(id -u):$(id -g) \
    --volume $(pwd):/data \
    --volume ~/.ssh/id_rsa_github_integration:/root/.ssh/id_rsa \
    devopsinfra/docker-terragrunt:aws-latest terragrunt apply --terragrunt-working-dir some/module

# Run a Makefile target as orchestration script.
docker run --rm \
    --tty --interactive \
    --user $(id -u):$(id -g) \
    --volume $(pwd):/data \
    devopsinfra/docker-terragrunt:aws-latest make build
```


# Additional software available in all images

### Scripts

| Script name         | Is included in PATH | Purpose                                                                                                                            | Source/Documentation                                                                           |
| ------------------- | ------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `format-hcl`        | Yes                 | For formatting all HCL files (`.hcl`, `.tf` and `.tfvars`) into format suggested by [Hashicorp](https://github.com/hashicorp/hcl). | [devops-infra](https://github.com/devops-infra/docker-terragrunt/blob/master/fmt/format-hcl)   |
| `terragrunt-fmt.sh` | No                  | Dependency for `format-hcl`                                                                                                        | [cytopia](https://github.com/cytopia/docker-terragrunt-fmt/blob/master/data/terragrunt-fmt.sh) |


### Binaries and Python libraries

| Name       | Type           | Description                                                                                                                                                    | Source/Documentation                               |
| ---------- | -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| bash       | Binary         | For color output from `terraform` and`terragrunt`. Assures also access to some builtins.                                                                       | https://www.gnu.org/software/bash/                 |
| curl       | Binary         | For interacting with [ElasticSearch](https://github.com/elastic/elasticsearch) and [Kibana](https://github.com/elastic/kibana).                                | https://curl.haxx.se/                              |
| docker     | Binary         | For running another container, e.g. for deploying Lambdas with [LambCI's](https://github.com/lambci) [docker-lambda](https://github.com/lambci/docker-lambda). | https://github.com/docker/docker-ce                |
| git        | Binary         | For interacting with [Github](https://github.com) repositories.                                                                                                | https://git-scm.com/                               |
| jq         | Binary         | For parsing JSON outputs of [awscli](https://github.com/aws/aws-cli).                                                                                          | https://stedolan.github.io/jq/                     |
| hcledit    | Binary         | For reading and writing HCL files.                                                                                                                             | https://github.com/minamijoyo/hcledit              |
| make       | Binary         | For using `Makefile` instead of scripts in deployment process.                                                                                                 | https://www.gnu.org/software/make/                 |
| ncurses    | Binary         | For expanding `Makefile` with some colors.                                                                                                                     | https://invisible-island.net/ncurses/announce.html |
| openssh    | Binary         | For allowing outgoing SSH connections.                                                                                                                         | https://www.openssh.com/                           |
| openssl    | Binary         | For calculating BASE64SHA256 hash of Lambda packages. Assures updating Lambdas only when package hash changed.                                                 | https://github.com/openssl/openssl                 |
| ply        | Python library | Dependency for [pyhcl](https://github.com/virtuald/pyhcl).                                                                                                     | https://github.com/dabeaz/ply                      |
| pyhcl      | Python library | For easily parsing of any files in HCL format, whether it's `.hcl`, `.tfvars` or `.tf`.                                                                        | https://github.com/virtuald/pyhcl                  |
| python3    | Binary         | For running more complex scripts during deployment process.                                                                                                    | https://www.python.org/                            |
| sops       | Binary         | For encrypting config files for Terragrunt's `sops_decrypt_file`.                                                                                              | https://github.com/mozilla/sops/                   |
| terraform  | Binary         | For managing IaC. Dependency for [Terragrunt](https://github.com/gruntwork-io/terragrunt).                                                                     | https://github.com/hashicorp/terraform             |
| terragrunt | Binary         | For managing IaC. Wrapper over [Terraform](https://github.com/hashicorp/terraform).                                                                            | https://github.com/gruntwork-io/terragrunt         |
| tflint     | Binary         | For linting Terraform files.                                                                                                                                   | https://github.com/terraform-linters/tflint        |
| zip        | Binary         | For creating packages for Lambdas.                                                                                                                             | http://infozip.sourceforge.net/                    |
