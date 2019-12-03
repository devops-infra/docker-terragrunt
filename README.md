# Docker image with Terraform/Terragrunt and all needed components to easily manage AWS infrastructure.

[![GitHub krzysztof-szyper-epam/docker-terragrunt](https://img.shields.io/badge/github-krzysztof--szyper--epam%2Fdocker--terragrunt-blue.svg)](https://github.com/krzysztof-szyper-epam/docker-terragrunt "shields.io")
[![Actions Status](https://github.com/Krzysztof-Szyper-Epam/docker-terragrunt/workflows/Build%20and%20push%20to%20Docker%20Hub/badge.svg)](https://github.com/Krzysztof-Szyper-Epam/docker-terragrunt/actions?query=workflow%3A%22Build+and+push+to+Docker+Hub%22 "github.com")
[![Actions Status](https://github.com/Krzysztof-Szyper-Epam/docker-terragrunt/workflows/Build%20on%20pull%20request/badge.svg)](https://github.com/Krzysztof-Szyper-Epam/docker-terragrunt/actions?query=workflow%3A%22Build+on+pull+request%22 "github.com")
![GitHub](https://img.shields.io/github/license/krzysztof-szyper-epam/docker-terragrunt "shields.io")
<br>
![GitHub last commit](https://img.shields.io/github/last-commit/krzysztof-szyper-epam/docker-terragrunt "shields.io")
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/krzysztof-szyper-epam/docker-terragrunt "shields.io")
![GitHub repo size](https://img.shields.io/github/repo-size/krzysztof-szyper-epam/docker-terragrunt "shields.io")
![GitHub search hit counter](https://img.shields.io/github/search/krzysztof-szyper-epam/docker-terragrunt/terragrunt "shields.io")
![GitHub language count](https://img.shields.io/github/languages/count/krzysztof-szyper-epam/docker-terragrunt "shields.io")
![GitHub top language](https://img.shields.io/github/languages/top/krzysztof-szyper-epam/docker-terragrunt "shields.io")
<br>
[![Docker Pulls](https://img.shields.io/docker/pulls/christophshyper/docker-terragrunt)](https://hub.docker.com/r/christophshyper/docker-terragrunt "shields.io")
![GitHub file size in bytes](https://img.shields.io/github/size/krzysztof-szyper-epam/docker-terragrunt/Dockerfile?label=Dockerfile "shields.io")
[![Docker Stars](https://img.shields.io/docker/stars/christophshyper/docker-terragrunt)](https://hub.docker.com/r/christophshyper/docker-terragrunt "shields.io")
[![MicroBadger Image](https://images.microbadger.com/badges/image/christophshyper/docker-terragrunt.svg)](https://microbadger.com/images/christophshyper/docker-terragrunt "Get your own image badge on microbadger.com")
[![MicroBadger Version](https://images.microbadger.com/badges/version/christophshyper/docker-terragrunt.svg)](https://microbadger.com/images/christophshyper/docker-terragrunt "Get your own version badge on microbadger.com")
[![MicroBadger Commit](https://images.microbadger.com/badges/commit/christophshyper/docker-terragrunt.svg)](https://microbadger.com/images/christophshyper/docker-terragrunt "Get your own commit badge on microbadger.com")
<br>
[![dockeri.co](https://dockeri.co/image/christophshyper/docker-terragrunt)](https://hub.docker.com/r/christophshyper/docker-terragrunt "dockeri.co")

Dockerfile is based on two images made by [cytopia](https://github.com/cytopia).
<br>
Those two images are [docker-terragrunt](https://github.com/cytopia/docker-terragrunt/tree/1bc1a2c6de42c6d19f7e91f64f30256c24fd386f) and [docker-terragrunt-fmt](https://github.com/cytopia/docker-terragrunt-fmt/tree/3f8964bea0db043a05d4a8d622f94a07f109b5a7).
<br>
Some changes have been applied to add more software to the image - list below.

Docker image is available at [DockerHub](https://hub.docker.com/) under [christophshyper/docker-terragrunt](https://hub.docker.com/repository/docker/christophshyper/docker-terragrunt).

Source code is available at [GitHub](https://github.com/) under [Krzysztof-Szyper-Epam/docker-terragrunt](https://github.com/Krzysztof-Szyper-Epam/docker-terragrunt).


# Available scripts
* format-hcl.sh
    * For formatting HCL files into format suggested by [Hashicorp](https://github.com/hashicorp/hcl)
    * Using [cytopia's](https://github.com/cytopia) [terragrunt-fmt.sh](https://github.com/cytopia/docker-terragrunt-fmt) plus additionally calling `terraform fmt`
    * Will search for fall HCL files recursively in work directory.


# Available binaries
* [awscli](https://github.com/aws/aws-cli) - For interacting with AWS infrastructure, e.g. for publishing Lambda packages to S3.
* [bash](https://www.gnu.org/software/bash/) - For color output from `terraform` and`terragrunt`. Assures also access to some builtins.
* [curl](https://curl.haxx.se/) - For interacting with [ElasticSearch](https://github.com/elastic/elasticsearch) and [Kibana](https://github.com/elastic/kibana).
* [docker](https://github.com/docker/docker-ce) - For running another container, e.g. for deploying Lambdas with [LambCI's](https://github.com/lambci) [docker-lambda](https://github.com/lambci/docker-lambda).
* [git](https://git-scm.com/) - For interacting with [Github](https://github.com) repositories.
* [jq](https://stedolan.github.io/jq/) - For parsing JSON outputs of [awscli](https://github.com/aws/aws-cli).
* [make](https://www.gnu.org/software/make/) - For using `Makefile` instead of scripts in deployment process.
* [openssl](https://github.com/openssl/openssl) - For calculating BASE64SHA256 hash of Lambda packages. Assures updating Lambdas only when package hash changed.
* [python3](https://www.python.org/) - For running more complex scripts during deployment process.
* [scenery](https://github.com/dmlittle/scenery) - For better coloring and visualization of `terraform plan` outputs.
* [terraform](https://github.com/hashicorp/terraform) - For managing IaC. Dependency for [Terragrunt](https://github.com/gruntwork-io/terragrunt). 
* [terragrunt](https://github.com/gruntwork-io/terragrunt) - For managing IaC. Wrapper over [Terraform](https://github.com/hashicorp/terraform).
* [zip](http://infozip.sourceforge.net/) - For creating packages for Lambdas.


# Available Python libraries
* [ply](https://github.com/dabeaz/ply) - Dependency for [pyhcl](https://github.com/virtuald/pyhcl)
* [pyhcl](https://github.com/virtuald/pyhcl) - For easily parsing of any file in HCL format, whether it's `.hcl`, `.tfvars` or `.tf`.
