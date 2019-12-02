[![Actions Status](https://github.com/Krzysztof-Szyper-Epam/docker-terragrunt/workflows/main/badge.svg)](https://github.com/Krzysztof-Szyper-Epam/docker-terragrunt/actions)

# Docker image with all components to easily manage Terraform/Terragrunt infrastructure.
Dockerfile is based on two images made by [cytopia](https://github.com/cytopia).

Those two images are [docker-terragrunt](https://github.com/cytopia/docker-terragrunt/tree/1bc1a2c6de42c6d19f7e91f64f30256c24fd386f) and [docker-terragrunt-fmt](https://github.com/cytopia/docker-terragrunt-fmt/tree/3f8964bea0db043a05d4a8d622f94a07f109b5a7).

Some changes have been applied to add more software to the image - list below.

Docker image is available at [DockerHub](https://hub.docker.com/) as [krzysztofszyperepam/docker-terragrunt](https://hub.docker.com/repository/docker/krzysztofszyperepam/docker-terragrunt)


# Available binaries
* [awscli](https://github.com/aws/aws-cli)
    * For interacting with AWS infrastructure, e.g. for publishing Lambda packages to S3.
* [docker](https://github.com/docker/docker-ce)
    * For running another container, e.g. for deploying Lambdas with [LambCI's](https://github.com/lambci) [docker-lambda](https://github.com/lambci/docker-lambda).
* [scenery](https://github.com/dmlittle/scenery)
    * For better coloring and visualization of `terraform plan` outputs.
* [terraform](https://github.com/hashicorp/terraform)
    * For managing IaC. Dependency for [Terragrunt](https://github.com/gruntwork-io/terragrunt). 
* [terragrunt](https://github.com/gruntwork-io/terragrunt)
    * For managing IaC. Wrapper over [Terraform](https://github.com/hashicorp/terraform).
* bash
    * For color output from `terraform` and`terragrunt`. Assures also access to some builtins.
* curl
    * For interacting with [ElasticSearch](https://github.com/elastic/elasticsearch) and [Kibana](https://github.com/elastic/kibana).
* git
    * For interacting with [Github](https://github.com) repositories.
* make
    * For using `Makefile` instead of scripts in deployment process.
* openssl
    * For calculating BASE64SHA256 hash of Lambda packages. Assures updating Lambdas only when package hash changed.
* python3
    * For running more complex scripts during deployment process.
* zip
    * For creating packages for Lambdas.


# Available Python libraries
* [ply](https://github.com/dabeaz/ply)
    * Dependency for [pyhcl](https://github.com/virtuald/pyhcl)
* [pyhcl](https://github.com/virtuald/pyhcl)
    * For easily parsing of any file in HCL format, whether it's `.hcl`, `.tfvars` or `.tf`.


# Available scripts
* format-hcl.sh
    * For formatting HCL files into format suggested by [Hashicorp](https://github.com/hashicorp/hcl)
    * Using [cytopia's](https://github.com/cytopia) [terragrunt-fmt.sh](https://github.com/cytopia/docker-terragrunt-fmt) plus additionally calling `terraform fmt`
