# Docker image for `terragrunt`

[![Build Status](https://travis-ci.com/cytopia/docker-terragrunt.svg?branch=master)](https://travis-ci.com/cytopia/docker-terragrunt)
[![Tag](https://img.shields.io/github/tag/cytopia/docker-terragrunt.svg)](https://github.com/cytopia/docker-terragrunt/releases)
[![](https://images.microbadger.com/badges/version/cytopia/terragrunt:latest.svg)](https://microbadger.com/images/cytopia/terragrunt:latest "terragrunt")
[![](https://images.microbadger.com/badges/image/cytopia/terragrunt:latest.svg)](https://microbadger.com/images/cytopia/terragrunt:latest "terragrunt")
[![](https://img.shields.io/badge/github-cytopia%2Fdocker--terragrunt-red.svg)](https://github.com/cytopia/docker-terragrunt "github.com/cytopia/docker-terragrunt")
[![License](https://img.shields.io/badge/license-MIT-%233DA639.svg)](https://opensource.org/licenses/MIT)

> #### All [#awesome-ci](https://github.com/topics/awesome-ci) Docker images
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

Tiny Alpine-based multistage-build dockerized version of [Terragrunt](https://github.com/gruntwork-io/terragrunt)<sup>[1]</sup>
and its comptaible version of [Terraform](https://github.com/hashicorp/terraform)<sup>[2]</sup>.

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

The working directory inside the Docker container is **`/data/`** and should be mounted to your local filesystem where your Terragrant project resides.
(See [Usage](#usage) for in-depth examples of mount locations.)


## Usage

### Generic
```bash
docker run --rm -v $(pwd):/data cytopia/terragrunt terragrunt <ARGS>
docker run --rm -v $(pwd):/data cytopia/terragrunt terraform <ARGS>
```

### Simple: Provision single sub-project on AWS
Let's assume your Terragrunt project setup is as follows:
```bash
/my/tf                                              # Terragrunt project root
├── backend-app
│   ├── main.tf
│   └── terragrunt.hcl
├── frontend-app
│   ├── main.tf
│   └── terragrunt.hcl
├── mysql                                           # MySQL sub-project directory
│   ├── main.tf
│   └── terragrunt.hcl
├── redis
│   ├── main.tf
│   └── terragrunt.hcl
└── vpc
    ├── main.tf
    └── terragrunt.hcl
```
The MySQL sub-project you want to provision is at the releative path `mysql/`.

1. Mount the terragrunt root project dir (`/my/tf/`) into `/data/` into the container
2. Use the workding dir (`-w` or `--workdir`) to point to your project inside the container
3. Add AWS credentials from your environment to the container

```bash
# Initialize the MySQL project
docker run --rm \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
  -v /my/tf:/data \
  -w /data/mysql \
  cytopia/terragrunt terragrunt init

# Plan the MySQL project
docker run --rm \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
  -v /my/tf:/data \
  -w /data/mysql \
  cytopia/terragrunt terragrunt plan

# Apply the VPC project
docker run --rm \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
  -v /my/tf:/data \
  -w /data/mysql \
  cytopia/terragrunt terragrunt --terragrunt-non-interactive apply
```

### Complex: Provision single sub-project on AWS
Let's assume your Terragrunt project setup is as follows:
```bash
/my/tf                                              # Terragrunt project root
└── envs
    └── aws
        ├── dev
        │   ├── eu-central-1
        │   │   ├── infra
        │   │   │   └── vpc-k8s                     # VPC sub-project directory
        │   │   │       ├── terraform.tfvars
        │   │   │       └── terragrunt.hcl
        │   │   ├── microservices
        │   │   │   └── api-gateway
        │   │   │       ├── terraform.tfvars
        │   │   │       └── terragrunt.hcl
        │   │   └── region.tfvars
        │   ├── global
        │   │   └── region.tfvars
        │   └── terragrunt.hcl
        └── _provider_include
            └── include_providers.tf
```
The VPC sub-project you want to provision is at the relative path `envs/aws/dev/eu-centra-1/infra/vpc-k8s/`.

1. Mount the terragrunt root project dir (`/my/tf/`) into `/data/` into the container
2. Use the workding dir (`-w` or `--workdir`) to point to your project inside the container
3. Add AWS credentials from your environment to the container

```bash
# Initialize the VPC project
docker run --rm \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
  -v /my/tf:/data \
  -w /data/envs/aws/dev/eu-central-1/infra/vpc-k8s \
  cytopia/terragrunt terragrunt init

# Plan the VPC project
docker run --rm \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
  -v /my/tf:/data \
  -w /data/envs/aws/dev/eu-central-1/infra/vpc-k8s \
  cytopia/terragrunt terragrunt plan

# Apply the MySQL project
docker run --rm \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
  -v /my/tf:/data \
  -w /data/envs/aws/dev/eu-central-1/infra/vpc-k8s \
  cytopia/terragrunt terragrunt --terragrunt-non-interactive apply
```


## License

**[MIT License](LICENSE)**

Copyright (c) 2019 [cytopia](https://github.com/cytopia)
