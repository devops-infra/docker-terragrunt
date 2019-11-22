# Docker image for `terragrunt-fmt`

[![Build Status](https://travis-ci.com/cytopia/docker-terragrunt-fmt.svg?branch=master)](https://travis-ci.com/cytopia/docker-terragrunt-fmt)
[![Tag](https://img.shields.io/github/tag/cytopia/docker-terragrunt-fmt.svg)](https://github.com/cytopia/docker-terragrunt-fmt/releases)
[![](https://images.microbadger.com/badges/version/cytopia/terragrunt-fmt:latest.svg?&kill_cache=1)](https://microbadger.com/images/cytopia/terragrunt-fmt:latest "terragrunt-fmt")
[![](https://images.microbadger.com/badges/image/cytopia/terragrunt-fmt:latest.svg?&kill_cache=1)](https://microbadger.com/images/cytopia/terragrunt-fmt:latest "terragrunt-fmt")
[![](https://img.shields.io/docker/pulls/cytopia/terragrunt-fmt.svg)](https://hub.docker.com/r/cytopia/terragrunt-fmt)
[![](https://img.shields.io/badge/github-cytopia%2Fdocker--terragrunt--fmt-red.svg)](https://github.com/cytopia/docker-terragrunt-fmt "github.com/cytopia/docker-terragrunt-fmt")
[![License](https://img.shields.io/badge/license-MIT-%233DA639.svg)](https://opensource.org/licenses/MIT)

> #### All [#awesome-ci](https://github.com/topics/awesome-ci) Docker images
>
> [ansible][ansible-git-lnk] **•**
> [ansible-lint][alint-git-lnk] **•**
> [awesome-ci][aci-git-lnk] **•**
> [black][black-git-lnk] **•**
> [checkmake][cm-git-lnk] **•**
> [eslint][elint-git-lnk] **•**
> [file-lint][flint-git-lnk] **•**
> [gofmt][gfmt-git-lnk] **•**
> [goimports][gimp-git-lnk] **•**
> [golint][glint-git-lnk] **•**
> [jsonlint][jlint-git-lnk] **•**
> [phpcbf][pcbf-git-lnk] **•**
> [phpcs][pcs-git-lnk] **•**
> [phplint][plint-git-lnk] **•**
> [php-cs-fixer][pcsf-git-lnk] **•**
> [pycodestyle][pycs-git-lnk] **•**
> [pylint][pylint-git-lnk] **•**
> [terraform-docs][tfdocs-git-lnk] **•**
> [terragrunt][tg-git-lnk] **•**
> [terragrunt-fmt][tgfmt-git-lnk] **•**
> [yamlfmt][yfmt-git-lnk] **•**
> [yamllint][ylint-git-lnk]

> #### All [#awesome-ci](https://github.com/topics/awesome-ci) Makefiles
>
> Visit **[cytopia/makefiles](https://github.com/cytopia/makefiles)** for seamless project integration, minimum required best-practice code linting and CI.

View **[Dockerfile](https://github.com/cytopia/docker-terragrunt-fmt/blob/master/Dockerfile)** on GitHub.

[![Docker hub](http://dockeri.co/image/cytopia/terragrunt-fmt?&kill_cache=1)](https://hub.docker.com/r/cytopia/terragrunt-fmt)

Tiny Alpine-based multistage-build dockerized version of [Terraform](https://github.com/hashicorp/terraform)<sup>[1]</sup> with the ability to do `terraform fmt` on Terragrunt files (`.hcl`).
This is achieved by creating a temporary file within the container with an `.tf` extension and then running `terraform fmt` on it.
Additionally the wrapper has been extended with a **`-ignore` argument** to be able to ignore files and directory or wildcards.
The image is built nightly against multiple stable versions and pushed to Dockerhub.

<sub>[1] Official project: https://github.com/hashicorp/terraform</sub>


## Available Docker image versions

The following Docker image tags are rolling releases and built and updated nightly. This means
they always contain the latest stable version as shown below.

| Docker tag   | Terraform version      |
|--------------|------------------------|
| `latest`     | latest stable          |
| `0.12`       | latest stable `0.12.x` |


## Docker mounts

The working directory inside the Docker container is **`/data/`** and should be mounted to your local filesystem where your Terragrant project resides.
(See [Examples](#examples) for mount location usage.)


## Usage
```
$ docker run --rm cytopia/terragrunt-fmt --help
```
```
Usage: cytopia/terragrunt-fmt [options] [DIR]
       cytopia/terragrunt-fmt --help
       cytopia/terragrunt-fmt --version

       Rewrites all Terragrunt configuration files to a canonical format. All
       hcl configuration files (.hcl) are updated.

       If DIR is not specified then the current working directory will be used.

Options:

  -list=true     List files whose formatting differs

  -write=false   Don't write to source files
                 (always disabled if using -check)

  -diff          Display diffs of formatting changes

  -check         Check if the input is formatted. Exit status will be 0 if all
                 input is properly formatted and non-zero otherwise.

  -recursive     Also process files in subdirectories. By default, only the
                 given directory (or current directory) is processed.

  -ignore=a,b    Comma separated list of paths to ignore.
                 The wildcard character '*' is supported.
```


## Examples

### List filenames that need to be fixed
```bash
$ docker run --rm -v $(pwd):/data cytopia/terragrunt-fmt -list

[INFO] Finding files: for file in *.hcl; do
terraform fmt -list=true -write=true validate.hcl
../tmp/validate.hcl.tf
```

### Show diff of files that need to be fixed
```bash
$ docker run --rm -v $(pwd):/data cytopia/terragrunt-fmt -diff

[INFO] Finding files: for file in *.hcl; do
terraform fmt -list=true -write=false -diff validate.hcl
../tmp/validate.hcl.tf
--- old/../tmp/validate.hcl.tf
+++ new/../tmp/validate.hcl.tf
@@ -35,9 +35,9 @@
 # which is not being used (disable_init)
 remote_state {
   backend = "s3"
-  config   = {
-    bucket   = "none"
-    key     = "none"
+  config = {
+    bucket = "none"
+    key    = "none"
     region = "eu-central-1"
   }
```

### Fix files
```bash
$ docker run --rm -v $(pwd):/data cytopia/terragrunt-fmt -write

[INFO] Finding files: for file in *.hcl; do
terraform fmt -list=true -write=true validate.hcl
../tmp/validate.hcl.tf
```

### Fix files and show diff
```bash
$ docker run --rm -v $(pwd):/data cytopia/terragrunt-fmt -write -diff

[INFO] Finding files: for file in *.hcl; do
terraform fmt -list=true -write=false -diff validate.hcl
../tmp/validate.hcl.tf
--- old/../tmp/validate.hcl.tf
+++ new/../tmp/validate.hcl.tf
@@ -35,9 +35,9 @@
 # which is not being used (disable_init)
 remote_state {
   backend = "s3"
-  config   = {
-    bucket   = "none"
-    key     = "none"
+  config = {
+    bucket = "none"
+    key    = "none"
     region = "eu-central-1"
   }
```

### List filenames that need to be fixed recursively
```bash
$ docker run --rm -v $(pwd):/data cytopia/terragrunt-fmt -list -recursive

[INFO] Finding files: find . -name '*.hcl' -type f
terraform fmt -list=true -write=false ./prod/eu-central-1/microservice/terragrunt.hcl
../tmp/terragrunt.hcl.tf
terraform fmt -list=true -write=false ./prod/eu-central-1/infra/terragrunt.hcl
../tmp/terragrunt.hcl.tf
```

### Show diff of files that need to be fixed recursively
```bash
$ docker run --rm -v $(pwd):/data cytopia/terragrunt-fmt -diff -recursive

[INFO] Finding files: find . -name '*.hcl' -type f
terraform fmt -list=true -write=false -diff ./prod/eu-central-1/microservice/terragrunt.hcl
../tmp/terragrunt.hcl.tf
--- old/../tmp/terragrunt.hcl.tf
+++ new/../tmp/terragrunt.hcl.tf
@@ -1,5 +1,5 @@
 terraform {
-   source  = "github.com/cytopia/terraform-aws-iam-cross-account?ref=v0.1.3"
+  source  = "github.com/cytopia/terraform-aws-iam-cross-account?ref=v0.1.3"
 }
terraform fmt -list=true -write=false -diff ./prod/eu-central-1/infra/terragrunt.hcl
../tmp/terragrunt.hcl.tf
--- old/../tmp/terragrunt.hcl.tf
+++ new/../tmp/terragrunt.hcl.tf
@@ -1,5 +1,5 @@
 terraform {
-   source  = "github.com/cytopia/terraform-aws-iam-cross-account?ref=v0.1.3"
+  source  = "github.com/cytopia/terraform-aws-iam-cross-account?ref=v0.1.3"
 }
```

### Fix recursively
```bash
$ docker run --rm -v $(pwd):/data cytopia/terragrunt-fmt -write -recursive

[INFO] Finding files: find . -name '*.hcl' -type f
terraform fmt -list=true -write=true ./prod/eu-central-1/microservice/terragrunt.hcl
../tmp/terragrunt.hcl.tf
terraform fmt -list=true -write=true ./prod/eu-central-1/infra/terragrunt.hcl
../tmp/terragrunt.hcl.tf
```

### Ignore files and directories

Ignore all files named `terragrunt.hcl`.
```bash
$ docker run --rm -v $(pwd):/data cytopia/terragrunt-fmt -recursive -ignore=*terragrunt.hcl

[INFO] Finding files: find . -not \( -path "./*terragrunt.hcl*" \) -name '*.hcl' -type f
terraform fmt -list=true -write=false ./aws/validate.hcl
../tmp/validate.hcl.tf
```

Ignore all directories named `dev/` and everything inside.
```bash
$ docker run --rm -v $(pwd):/data cytopia/terragrunt-fmt -recursive -ignore=*/dev/

[INFO] Finding files: find . -not \( -path "./*/dev/*" \) -name '*.hcl' -type f
terraform fmt -list=true -write=false ./prod/eu-central-1/microservice/terragrunt.hcl
../tmp/terragrunt.hcl.tf
terraform fmt -list=true -write=false ./prod/eu-central-1/infra/terragrunt.hcl
../tmp/terragrunt.hcl.tf
```

Ignore all directories named `dev/` and `testing/` and everything inside.
```bash
$ docker run --rm -v $(pwd):/data cytopia/terragrunt-fmt -recursive -ignore=*/dev/,*/testing/

[INFO] Finding files: find . -not \( -path "./*/dev/*" -o -path "./*/testing/*" \) -name '*.hcl' -type f
terraform fmt -list=true -write=false ./prod/eu-central-1/microservice/terragrunt.hcl
../tmp/terragrunt.hcl.tf
terraform fmt -list=true -write=false ./prod/eu-central-1/infra/terragrunt.hcl
../tmp/terragrunt.hcl.tf
```


## Project and CI integration

#### Makefile
You can add the following Makefile to your project for easy linting anf fixing of Terragrunt `.hcl` files.
```make
ifneq (,)
.error This Makefile requires GNU Make.
endif

.PHONY: help lint fix _pull

CURRENT_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Adjust according to your needs
IGNORE      = */.terragrunt-cache/,*/.terraform/
FMT_VERSION = latest

help:
	@echo "help    Show this help"
	@echo "lint    Exit > 0 if any files have wrong formatting"
	@echo "fix     Fix all .hcl files"

lint: _pull
	docker run --rm -v $(CURRENT_DIR):/data cytopia/terragrunt-fmt:$(FMT_VERSION) \
		-check -diff -recursive -ignore='$(IGNORE)'

fix: _pull
	docker run --rm -v $(CURRENT_DIR):/data cytopia/terragrunt-fmt:$(FMT_VERSION) \
		-write -diff -recursive -ignore='$(IGNORE)'

_pull:
	docker pull cytopia/terragrunt-fmt:$(FMT_VERSION)
```

#### Travis CI integration
With the above Makefile in place, you can easily add a Travis CI rule to ensure the Terragrunt code
uses correct coding style.

```yml
---
sudo: required
language: minimal
services:
  - docker
script:
  - make lint
```


## Related [#awesome-ci](https://github.com/topics/awesome-ci) projects

### Docker images

Save yourself from installing lot's of dependencies and pick a dockerized version of your favourite
linter below for reproducible local or remote CI tests:

| GitHub | DockerHub | Type | Description |
|--------|-----------|------|-------------|
| [awesome-ci][aci-git-lnk]        | [![aci-hub-img]][aci-hub-lnk]         | Basic      | Tools for git, file and static source code analysis |
| [file-lint][flint-git-lnk]       | [![flint-hub-img]][flint-hub-lnk]     | Basic      | Baisc source code analysis |
| [ansible][ansible-git-lnk]       | [![ansible-hub-img]][ansible-hub-lnk] | Ansible    | Multiple versions and flavours of Ansible |
| [ansible-lint][alint-git-lnk]    | [![alint-hub-img]][alint-hub-lnk]     | Ansible    | Lint Ansible |
| [gofmt][gfmt-git-lnk]            | [![gfmt-hub-img]][gfmt-hub-lnk]       | Go         | Format Go source code **<sup>[1]</sup>** |
| [goimports][gimp-git-lnk]        | [![gimp-hub-img]][gimp-hub-lnk]       | Go         | Format Go source code **<sup>[1]</sup>** |
| [golint][glint-git-lnk]          | [![glint-hub-img]][glint-hub-lnk]     | Go         | Lint Go code |
| [eslint][elint-git-lnk]          | [![elint-hub-img]][elint-hub-lnk]     | Javascript | Lint Javascript code |
| [jsonlint][jlint-git-lnk]        | [![jlint-hub-img]][jlint-hub-lnk]     | JSON       | Lint JSON files **<sup>[1]</sup>** |
| [checkmake][cm-git-lnk]          | [![cm-hub-img]][cm-hub-lnk]           | Make       | Lint Makefiles |
| [phpcbf][pcbf-git-lnk]           | [![pcbf-hub-img]][pcbf-hub-lnk]       | PHP        | PHP Code Beautifier and Fixer |
| [phpcs][pcs-git-lnk]             | [![pcs-hub-img]][pcs-hub-lnk]         | PHP        | PHP Code Sniffer |
| [phplint][plint-git-lnk]         | [![plint-hub-img]][plint-hub-lnk]     | PHP        | PHP Code Linter **<sup>[1]</sup>** |
| [php-cs-fixer][pcsf-git-lnk]     | [![pcsf-hub-img]][pcsf-hub-lnk]       | PHP        | PHP Coding Standards Fixer |
| [black][black-git-lnk]           | [![black-hub-img]][black-hub-lnk]     | Python     | The uncompromising Python code formatter |
| [pycodestyle][pycs-git-lnk]      | [![pycs-hub-img]][pycs-hub-lnk]       | Python     | Python style guide checker |
| [pylint][pylint-git-lnk]         | [![pylint-hub-img]][pylint-hub-lnk]   | Python     | Python source code, bug and quality checker |
| [terraform-docs][tfdocs-git-lnk] | [![tfdocs-hub-img]][tfdocs-hub-lnk]   | Terraform  | Terraform doc generator (TF 0.12 ready) **<sup>[1]</sup>** |
| [terragrunt][tg-git-lnk]         | [![tg-hub-img]][tg-hub-lnk]           | Terraform  | Terragrunt and Terraform |
| [terragrunt-fmt][tgfmt-git-lnk]  | [![tgfmt-hub-img]][tgfmt-hub-lnk]     | Terraform  | `terraform fmt` for Terragrunt files **<sup>[1]</sup>** |
| [yamlfmt][yfmt-git-lnk]          | [![yfmt-hub-img]][yfmt-hub-lnk]       | Yaml       | Format Yaml files **<sup>[1]</sup>** |
| [yamllint][ylint-git-lnk]        | [![ylint-hub-img]][ylint-hub-lnk]     | Yaml       | Lint Yaml files |

> **<sup>[1]</sup>** Uses a shell wrapper to add **enhanced functionality** not available by original project.

[aci-git-lnk]: https://github.com/cytopia/awesome-ci
[aci-hub-img]: https://img.shields.io/docker/pulls/cytopia/awesome-ci.svg
[aci-hub-lnk]: https://hub.docker.com/r/cytopia/awesome-ci

[flint-git-lnk]: https://github.com/cytopia/docker-file-lint
[flint-hub-img]: https://img.shields.io/docker/pulls/cytopia/file-lint.svg
[flint-hub-lnk]: https://hub.docker.com/r/cytopia/file-lint

[jlint-git-lnk]: https://github.com/cytopia/docker-jsonlint
[jlint-hub-img]: https://img.shields.io/docker/pulls/cytopia/jsonlint.svg
[jlint-hub-lnk]: https://hub.docker.com/r/cytopia/jsonlint

[ansible-git-lnk]: https://github.com/cytopia/docker-ansible
[ansible-hub-img]: https://img.shields.io/docker/pulls/cytopia/ansible.svg
[ansible-hub-lnk]: https://hub.docker.com/r/cytopia/ansible

[alint-git-lnk]: https://github.com/cytopia/docker-ansible-lint
[alint-hub-img]: https://img.shields.io/docker/pulls/cytopia/ansible-lint.svg
[alint-hub-lnk]: https://hub.docker.com/r/cytopia/ansible-lint

[gfmt-git-lnk]: https://github.com/cytopia/docker-gofmt
[gfmt-hub-img]: https://img.shields.io/docker/pulls/cytopia/gofmt.svg
[gfmt-hub-lnk]: https://hub.docker.com/r/cytopia/gofmt

[gimp-git-lnk]: https://github.com/cytopia/docker-goimports
[gimp-hub-img]: https://img.shields.io/docker/pulls/cytopia/goimports.svg
[gimp-hub-lnk]: https://hub.docker.com/r/cytopia/goimports

[glint-git-lnk]: https://github.com/cytopia/docker-golint
[glint-hub-img]: https://img.shields.io/docker/pulls/cytopia/golint.svg
[glint-hub-lnk]: https://hub.docker.com/r/cytopia/golint

[elint-git-lnk]: https://github.com/cytopia/docker-eslint
[elint-hub-img]: https://img.shields.io/docker/pulls/cytopia/eslint.svg
[elint-hub-lnk]: https://hub.docker.com/r/cytopia/eslint

[cm-git-lnk]: https://github.com/cytopia/docker-checkmake
[cm-hub-img]: https://img.shields.io/docker/pulls/cytopia/checkmake.svg
[cm-hub-lnk]: https://hub.docker.com/r/cytopia/checkmake

[pcbf-git-lnk]: https://github.com/cytopia/docker-phpcbf
[pcbf-hub-img]: https://img.shields.io/docker/pulls/cytopia/phpcbf.svg
[pcbf-hub-lnk]: https://hub.docker.com/r/cytopia/phpcbf

[pcs-git-lnk]: https://github.com/cytopia/docker-phpcs
[pcs-hub-img]: https://img.shields.io/docker/pulls/cytopia/phpcs.svg
[pcs-hub-lnk]: https://hub.docker.com/r/cytopia/phpcs

[plint-git-lnk]: https://github.com/cytopia/docker-phplint
[plint-hub-img]: https://img.shields.io/docker/pulls/cytopia/phplint.svg
[plint-hub-lnk]: https://hub.docker.com/r/cytopia/phplint

[pcsf-git-lnk]: https://github.com/cytopia/docker-php-cs-fixer
[pcsf-hub-img]: https://img.shields.io/docker/pulls/cytopia/php-cs-fixer.svg
[pcsf-hub-lnk]: https://hub.docker.com/r/cytopia/php-cs-fixer

[black-git-lnk]: https://github.com/cytopia/docker-black
[black-hub-img]: https://img.shields.io/docker/pulls/cytopia/black.svg
[black-hub-lnk]: https://hub.docker.com/r/cytopia/black

[pycs-git-lnk]: https://github.com/cytopia/docker-pycodestyle
[pycs-hub-img]: https://img.shields.io/docker/pulls/cytopia/pycodestyle.svg
[pycs-hub-lnk]: https://hub.docker.com/r/cytopia/pycodestyle

[pylint-git-lnk]: https://github.com/cytopia/docker-pylint
[pylint-hub-img]: https://img.shields.io/docker/pulls/cytopia/pylint.svg
[pylint-hub-lnk]: https://hub.docker.com/r/cytopia/pylint

[tfdocs-git-lnk]: https://github.com/cytopia/docker-terraform-docs
[tfdocs-hub-img]: https://img.shields.io/docker/pulls/cytopia/terraform-docs.svg
[tfdocs-hub-lnk]: https://hub.docker.com/r/cytopia/terraform-docs

[tg-git-lnk]: https://github.com/cytopia/docker-terragrunt
[tg-hub-img]: https://img.shields.io/docker/pulls/cytopia/terragrunt.svg
[tg-hub-lnk]: https://hub.docker.com/r/cytopia/terragrunt

[tgfmt-git-lnk]: https://github.com/cytopia/docker-terragrunt-fmt
[tgfmt-hub-img]: https://img.shields.io/docker/pulls/cytopia/terragrunt-fmt.svg
[tgfmt-hub-lnk]: https://hub.docker.com/r/cytopia/terragrunt-fmt

[yfmt-git-lnk]: https://github.com/cytopia/docker-yamlfmt
[yfmt-hub-img]: https://img.shields.io/docker/pulls/cytopia/yamlfmt.svg
[yfmt-hub-lnk]: https://hub.docker.com/r/cytopia/yamlfmt

[ylint-git-lnk]: https://github.com/cytopia/docker-yamllint
[ylint-hub-img]: https://img.shields.io/docker/pulls/cytopia/yamllint.svg
[ylint-hub-lnk]: https://hub.docker.com/r/cytopia/yamllint


### Makefiles

Visit **[cytopia/makefiles](https://github.com/cytopia/makefiles)** for dependency-less, seamless project integration and minimum required best-practice code linting for CI.
The provided Makefiles will only require GNU Make and Docker itself removing the need to install anything else.


## License

**[MIT License](LICENSE)**

Copyright (c) 2019 [cytopia](https://github.com/cytopia)
