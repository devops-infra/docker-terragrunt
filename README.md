# Docker image for `terragrunt`

[![Build Status](https://travis-ci.com/cytopia/docker-terragrunt.svg?branch=master)](https://travis-ci.com/cytopia/docker-terragrunt)
[![Tag](https://img.shields.io/github/tag/cytopia/docker-terragrunt.svg)](https://github.com/cytopia/docker-terragrunt/releases)
[![](https://images.microbadger.com/badges/version/cytopia/terragrunt:latest.svg)](https://microbadger.com/images/cytopia/terragrunt:latest "terragrunt")
[![](https://images.microbadger.com/badges/image/cytopia/terragrunt:latest.svg)](https://microbadger.com/images/cytopia/terragrunt:latest "terragrunt")
[![](https://img.shields.io/badge/github-cytopia%2Fdocker--terragrunt-red.svg)](https://github.com/cytopia/docker-terragrunt "github.com/cytopia/docker-terragrunt")
[![License](https://img.shields.io/badge/license-MIT-%233DA639.svg)](https://opensource.org/licenses/MIT)

> #### All awesome CI Docker images
>
> [ansible](https://github.com/cytopia/docker-ansible) |
> [ansible-lint](https://github.com/cytopia/docker-ansible-lint) |
> [awesome-ci](https://github.com/cytopia/awesome-ci) |
> [eslint](https://github.com/cytopia/docker-eslint) |
> [file-lint](https://github.com/cytopia/docker-file-lint) |
> [jsonlint](https://github.com/cytopia/docker-jsonlint) |
> [pycodestyle](https://github.com/cytopia/docker-pycodestyle) |
> [terraform-docs](https://github.com/cytopia/docker-terraform-docs) |
> [terragrunt](https://github.com/cytopia/docker-terragrunt) |
> [yamllint](https://github.com/cytopia/docker-yamllint)


View **[Dockerfile](https://github.com/cytopia/docker-terragrunt/blob/master/Dockerfile)** on GitHub.

[![Docker hub](http://dockeri.co/image/cytopia/terragrunt)](https://hub.docker.com/r/cytopia/terragrunt)

Tiny Alpine-based multistage-build dockerized version of [terragrunt](https://github.com/gruntwork-io/terragrunt)<sup>[1]</sup>
and its corresponding version of [terraform](https://github.com/hashicorp/terraform)<sup>[2]</sup>.

* <sub>[1] Official project: https://github.com/gruntwork-io/terragrunt</sub>
* <sub>[2] Official project: https://github.com/hashicorp/terraform</sub>


## Available Docker image versions

### Rolling releases
The following Docker image tags are rolling releases and built and updated nightly. This means
they always contain the latest stable version as shown below.

| Docker tag   | Terraform version      | Terragrunt version     |
|--------------|------------------------|------------------------|
| `latest`     | latest stable          | latest stable          |
| `0.12-0.19`  | latest stable `0.12.x` | latest stable `0.19.x` |
| `0.11-0.18`  | latest stable `0.11.x` | latest stable `0.18.x` |


### Point in time releases
If you want to ensure to have reproducible Terraform/Terragrunt executions you should use a git tag from
this repository. Tags are incremented for each new version, but never updated itself. This means
you will have to take care yourself and update your CI tools every time a new tag is being released.

| Docker tag        | docker-terragrunt | Terraform version                          | Terragrunt version                         |
|-------------------|-------------------|--------------------------------------------|--------------------------------------------|
| `latest-<tag>`    | Tag: `<tag>`      | latest stable during tag creation          | latest stable during tag creation          |
| `0.12-0.19-<tag>` | Tag: `<tag>`      | latest stable `0.12.x` during tag creation | latest stable `0.12.x` during tag creation |
| `0.11-0.18-<tag>` | Tag: `<tag>`      | latest stable `0.11.x` during tag creation | latest stable `0.11.x` during tag creation |

Where `<tag>` refers to the chosen git tag from this repository.


## Docker mounts

The working directory inside the Docker container is **`/data/`** and should be mounted to your local filesystem.


## Usage

### Generic
```bash
docker run --rm -v $(pwd):/data cytopia/terragrunt terragrunt <ARGS>
docker run --rm -v $(pwd):/data cytopia/terragrunt terraform <ARGS>
```

### Provision single sub-project on AWS
Let's assume your Terragrunt project setup is as follows:
```
/my/tf                                              # Terragrunt project root
└── envs
    └── aws
        ├── dev
        │   ├── eu-central-1
        │   │   ├── infra
        │   │   │   └── vpc-k8s                     # VPC sub-project directory
        │   │   │       ├── include_providers.tf
        │   │   │       ├── terraform.tfvars
        │   │   │       └── terragrunt.hcl
        │   │   ├── microservices
        │   │   │   └── api-gateway
        │   │   │       ├── include_providers.tf
        │   │   │       ├── terraform.tfvars
        │   │   │       └── terragrunt.hcl
        │   │   └── region.tfvars
        │   ├── global
        │   │   └── region.tfvars
        │   └── terragrunt.hcl
        └── _provider_include
            └── include_providers.tf
```
The VPC sub-project you want to provision is at the path `envs/aws/dev/eu-centra-1/infra/vpc-k8s/`.

1. Mount the terragrunt root project dir (`/my/tf/`) into `/data/` into the container
2. Use the workding dir (`-w` or `--workdir`) to point to your project inside the container
3. Add AWS credentials from your environment to the container

```bash
# Initialize the VPC project
docker run --rm \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
  -v /my/tf:/data cytopia/terragrunt \
  -w /data/envs/aws/dev/eu-central-1/infra/vpc-k8s \
  terragrunt init

# Plan the VPC project
docker run --rm \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
  -v /my/tf:/data cytopia/terragrunt \
  -w /data/envs/aws/dev/eu-central-1/infra/vpc-k8s \
  terragrunt plan

# Apply the VPC project
docker run --rm \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
  -v /my/tf:/data cytopia/terragrunt \
  -w /data/envs/aws/dev/eu-central-1/infra/vpc-k8s \
  terragrunt --terragrunt-non-interactive apply
```


## License

**[MIT License](LICENSE)**

Copyright (c) 2019 [cytopia](https://github.com/cytopia)
