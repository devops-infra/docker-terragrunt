# Dockerized IaC framework for Terraform, OpenTofu and Terragrunt

### Supporting `amd64` and `arm64` images!

### Due to excessive size of the images and upcoming Docker Hub limits, I'm are currently working on reducing it. Please use the latest versions of the images to keep up with the most active versions. Images older than 3 month will be deleted.

## Sources and Docker images

**Source code** at [devops-infra/docker-terragrunt](https://github.com/devops-infra/docker-terragrunt).

**Docker Hub** images at [docker.io/devopsinfra/docker-terragrunt](https://hub.docker.com/repository/docker/devopsinfra/docker-terragrunt)

**GitHub Packages** images at [ghcr.io/devops-infra/docker-terragrunt/docker-terragrunt](https://github.com/devops-infra/docker-terragrunt/pkgs/container/docker-terragrunt)


# Info

Docker image with Terraform or OpenTofu, together with Terragrunt, Go, Python, Make, Docker, Git, and all needed components to easily manage cloud  infrastructure for CI/CD environments as a runner image.

Including cloud CLIs and SDKs for **Amazon Web Services, Microsoft Azure, Google Cloud Platform**.

**Best used as runner image for CI/CD in automation, as well as a consistent local run environment.**

Please note focus of those images is to maintain availability of current versions of **Terraform, OpenTofu and Terragrunt**, not CLIs or other dependencies.
Hence, images are updated when new version of Terraform, OpenTofu or Terragrunt is released. Furthermore, versioning labels of images contain versions of said software to emphasize it.


Dockerfile was based on two images made
by [cytopia](https://github.com/cytopia): [docker-terragrunt](https://github.com/cytopia/docker-terragrunt)
and [docker-terragrunt-fmt](https://github.com/cytopia/docker-terragrunt-fmt)
.
Original README files are included in this
repository: [docker-terragrunt](https://github.com/devopsinfra/docker-terragrunt/blob/master/README.docker-terragrunt.md)
and [docker-terragrunt-fmt](https://github.com/devopsinfra/docker-terragrunt/blob/master/README.docker-terragrunt-fmt.md)
. This project grew much bigger than the original ones and is intended to be a framework for cloud
Infrastructure-as-a-Code.


<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-7-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

<a href="https://gitmoji.dev">
  <img
    src="https://img.shields.io/badge/gitmoji-%20😜%20😍-FFDD67.svg?style=flat-square"
    alt="Gitmoji"
  />
</a>

[
![GitHub](https://img.shields.io/badge/github-devops--infra%2Fdocker--terragrunt-brightgreen.svg?style=flat-square&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/devops-infra/docker-terragrunt?color=brightgreen&label=Last%20commit&style=flat-square&logo=github)
](https://github.com/devops-infra/docker-terragrunt "shields.io")

[
![DockerHub](https://img.shields.io/badge/docker-devopsinfra%2Fdocker--terragrunt-blue.svg?style=flat-square&logo=docker)
![Docker Pulls](https://img.shields.io/docker/pulls/devopsinfra/docker-terragrunt?color=blue&label=Pulls&logo=docker&style=flat-square)
](https://hub.docker.com/r/devopsinfra/docker-terragrunt "shields.io")


# Available source images

Tag of the image tells which version of Terraform and Terragrunt it contains and which public cloud provider CLI it's
bundled with or not (see second table below).


| Current release full tag version value |
|:---------------------------------------|
| `tf-1.14.8-ot-1.11.5-tg-1.0.0`         |


| Registry                                                                             | Example full image name                                                       | Image name          | Image version        | Terraform version | OpenTofu version | Terragrunt version |
|--------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|---------------------|----------------------|-------------------|------------------|--------------------|
| [Docker Hub](https://hub.docker.com/repository/docker/devopsinfra/docker-terragrunt) | `devopsinfra/docker-terragrunt:tf-1.14.8-tg-1.0.0`                            | `docker-terragrunt` | `tf-1.14.8-tg-1.0.0` | `1.14.8`          | `N/A`            | `1.0.0`            |
| [Docker Hub](https://hub.docker.com/repository/docker/devopsinfra/docker-terragrunt) | `devopsinfra/docker-terragrunt:ot-1.11.5-tg-1.0.0`                            | `docker-terragrunt` | `ot-1.11.5-tg-1.0.0` | `N/A`             | `1.11.5`         | `1.0.0`            |
| [GitHub Packages](https://github.com/devops-infra/docker-terragrunt/packages)        | `ghcr.io/devops-infra/docker-terragrunt/docker-terragrunt:tf-1.14.8-tg-1.0.0` | `docker-terragrunt` | `tf-1.14.8-tg-1.0.0` | `1.14.8`          | `N/A`            | `1.0.0`            |
| [GitHub Packages](https://github.com/devops-infra/docker-terragrunt/packages)        | `ghcr.io/devops-infra/docker-terragrunt/docker-terragrunt:ot-1.11.5-tg-1.0.0` | `docker-terragrunt` | `ot-1.11.5-tg-1.0.0` | `N/A`             | `1.11.5`         | `1.0.0`            |


# Available flavors

Tag of the image tells also which cloud API/SDK is included in the image.

| Image name                                  | AWS | Azure | GCP | OT | TF | Description                                                                                                                                                                                                               |
|---------------------------------------------|-----|-------|-----|----|----|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `docker-terragrunt:slim-tf-latest`          | ❌   | ❌     | ❌   | ❌  | ✅  | Lightweight version with TF, TG and bare dependencies. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/slim-tf-latest?label=Image%20size&style=flat-square&logo=docker)         |
| `docker-terragrunt:slim-ot-latest`          | ❌   | ❌     | ❌   | ✅  | ❌  | Lightweight version with OT, TG and bare dependencies. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/slim-ot-latest?label=Image%20size&style=flat-square&logo=docker)         |
| `docker-terragrunt:tf-latest`               | ❌   | ❌     | ❌   | ❌  | ✅  | Normal version, with TF. Having Go, Python, Make, etc. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/tf-latest?label=Image%20size&style=flat-square&logo=docker)              |
| `docker-terragrunt:ot-latest`               | ❌   | ❌     | ❌   | ✅  | ❌  | Normal version, with OT. Having Go, Python, Make, etc. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/ot-latest?label=Image%20size&style=flat-square&logo=docker)              |
| `docker-terragrunt:aws-tf-latest`           | ✅   | ❌     | ❌   | ❌  | ✅  | Normal version with AWS CLI, with TF. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/aws-tf-latest?label=Image%20size&style=flat-square&logo=docker)                           |
| `docker-terragrunt:aws-ot-latest`           | ✅   | ❌     | ❌   | ✅  | ❌  | Normal version with AWS CLI, with OT. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/aws-ot-latest?label=Image%20size&style=flat-square&logo=docker)                           |
| `docker-terragrunt:azure-tf-latest`         | ❌   | ✅     | ❌   | ❌  | ✅  | Normal version with Azure CLI, with TF. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/azure-tf-latest?label=Image%20size&style=flat-square&logo=docker)                       |
| `docker-terragrunt:azure-ot-latest`         | ❌   | ✅     | ❌   | ✅  | ❌  | Normal version with Azure CLI, with OT. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/azure-ot-latest?label=Image%20size&style=flat-square&logo=docker)                       |
| `docker-terragrunt:aws-azure-tf-latest`     | ✅   | ✅     | ❌   | ❌  | ✅  | Normal version with AWS and Azure CLIs, with TF. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/aws-azure-tf-latest?label=Image%20size&style=flat-square&logo=docker)          |
| `docker-terragrunt:aws-azure-ot-latest`     | ✅   | ✅     | ❌   | ✅  | ❌  | Normal version with AWS and Azure CLIs, with OT. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/aws-azure-ot-latest?label=Image%20size&style=flat-square&logo=docker)          |
| `docker-terragrunt:gcp-tf-latest`           | ❌   | ❌     | ✅   | ❌  | ✅  | Normal version with GCP CLI, with TF. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/gcp-tf-latest?label=Image%20size&style=flat-square&logo=docker)                           |
| `docker-terragrunt:gcp-ot-latest`           | ❌   | ❌     | ✅   | ✅  | ❌  | Normal version with GCP CLI, with OT. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/gcp-ot-latest?label=Image%20size&style=flat-square&logo=docker)                           |
| `docker-terragrunt:aws-gcp-tf-latest`       | ✅   | ❌     | ✅   | ❌  | ✅  | Normal version with AWS and GCP CLIs, with TF. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/aws-gcp-tf-latest?label=Image%20size&style=flat-square&logo=docker)              |
| `docker-terragrunt:aws-gcp-ot-latest`       | ✅   | ❌     | ✅   | ✅  | ❌  | Normal version with AWS and GCP CLIs, with OT. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/aws-gcp-ot-latest?label=Image%20size&style=flat-square&logo=docker)              |
| `docker-terragrunt:azure-gcp-tf-latest`     | ❌   | ✅     | ✅   | ❌  | ✅  | Normal version with Azure and GCP CLIs, with TF. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/azure-gcp-tf-latest?label=Image%20size&style=flat-square&logo=docker)          |
| `docker-terragrunt:azure-gcp-ot-latest`     | ❌   | ✅     | ✅   | ✅  | ❌  | Normal version with Azure and GCP CLIs, with OT. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/azure-gcp-ot-latest?label=Image%20size&style=flat-square&logo=docker)          |
| `docker-terragrunt:aws-azure-gcp-tf-latest` | ✅   | ✅     | ✅   | ❌  | ✅  | Normal version with AWS, Azure and GCP CLIs, with TF. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/aws-azure-gcp-tf-latest?label=Image%20size&style=flat-square&logo=docker) |
| `docker-terragrunt:aws-azure-gcp-ot-latest` | ✅   | ✅     | ✅   | ✅  | ❌  | Normal version with AWS, Azure and GCP CLIs, with OT. <br>![Docker size](https://img.shields.io/docker/image-size/devopsinfra/docker-terragrunt/aws-azure-gcp-ot-latest?label=Image%20size&style=flat-square&logo=docker) |


## Test coverage matrix

Container-structure-tests validate both positive and negative cases for installed software.
For each flavor, tests run against both image variants (`-tf-...` and `-ot-...`).

| Flavor          | Expected cloud CLIs present | Expected cloud CLIs absent | Extra constraints checked                                                                  |
|-----------------|-----------------------------|----------------------------|--------------------------------------------------------------------------------------------|
| `slim`          | none                        | `aws`, `az`, `gcloud`      | `curl`, `git`, `jq`, `vim`, `wget`, `unzip`                                                |
| `plain`         | none                        | `aws`, `az`, `gcloud`      | slim flavor + `task`, `make`, `docker`, `go`, `python3`, `tflint`, `hcledit`, `sops`, etc. |
| `aws`           | `aws`                       | `az`, `gcloud`             | plain flavor + `boto3`                                                                     |
| `azure`         | `az`                        | `aws`, `gcloud`            | plain flavor                                                                               |
| `gcp`           | `gcloud`                    | `aws`, `az`                | plain flavor                                                                               |
| `aws-azure`     | `aws`, `az`                 | `gcloud`                   | plain flavor                                                                               |
| `aws-gcp`       | `aws`, `gcloud`             | `az`                       | plain flavor                                                                               |
| `azure-gcp`     | `az`, `gcloud`              | `aws`                      | plain flavor                                                                               |
| `aws-azure-gcp` | `aws`, `az`, `gcloud`       | none                       | plain flavor                                                                               |

Additionally, tool-variant tests verify:
- TF image contains the exact Terraform version and does not contain OpenTofu.
- OT image contains the exact OpenTofu version and does not contain Terraform.
- Both variants validate exact Terragrunt and flavor-specific tool versions sourced from Dockerfile ARG values.


# Usage

* For working with local files - mount working directory under `/data`, e.g. `--volume $(pwd):/data`.
* For working with cloud providers - pass their credentials as additional file or environment variables,
  e.g. `--env AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}` or `--volume ~/.aws/credentials:/root/.aws/credentials`.
* For running other Docker images - by sharing the socket,
  e.g. `--privileged --volume /var/run/docker.sock:/var/run/docker.sock`.
* For configuring git - mount desired `.gitconfig` and/or SSH key (if needed),
  e.g. `--volume ~/.gitconfig:/root/.gitconfig --volume ~/.ssh/id_rsa_github:/root/.ssh/id_rsa`


### Examples of `.gitconfig` to mount

* Use https with Personal Access Token:
```
[url "https://{GITHUB_TOKEN}@github.com/"]
	insteadOf = https://github.com/
[url "https://{GITHUB_TOKEN}@github.com/"]
	insteadOf = git+ssh://github.com/
[url "https://{GITHUB_TOKEN}@github.com/"]
	insteadOf = git@github.com:
```

* Use https instead of git/ssh:
```
[url "https://github.com/"]
	insteadOf = git+ssh://github.com/
[url "https://github.com/"]
	insteadOf = git@github.com:
```

* Use ssh instead of https:
```
[url "ssh://git@github.com/"]
  insteadOf = https://github.com/
[url "ssh://git@github.com/"]
	insteadOf = git@github.com:
```


# Examples

* Format all HCL files in the current directory. Including subdirectories.

```bash
docker run --rm \
    --user $(id -u):$(id -g) \
    --volume $(pwd):/data \
    devopsinfra/docker-terragrunt:latest format-hcl
```

* Plan terraform deployment in AWS for files in current directory.

```bash
docker run --rm \
    --tty --interactive \
    --env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
    --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    --env AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
    --user $(id -u):$(id -g) \
    --volume $(pwd):/data \
    devopsinfra/docker-terragrunt:aws-latest terraform plan
```

* Apply terragrunt deployment in subdirectory. With GitHub using a `~/.gitconfig` file with PAT.

```bash
docker run --rm \
    --tty --interactive \
    --user $(id -u):$(id -g) \
    --volume $(pwd):/data \
    --volume ~/.gitconfig:/root/.gitconfig \
    devopsinfra/docker-terragrunt:aws-latest terragrunt apply --terragrunt-working-dir some/module
```

* Run a Makefile target as orchestration script.

```bash
docker run --rm \
    --tty --interactive \
    --user $(id -u):$(id -g) \
    --volume $(pwd):/data \
    devopsinfra/docker-terragrunt:latest make build
```


# Additional software available in all images

### Scripts

| Script name         | Is included in PATH | Purpose                                                                                                                            | Source/Documentation                                                                           |
|---------------------|---------------------|------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|
| `format-hcl`        | Yes                 | For formatting all HCL files (`.hcl`, `.tf` and `.tfvars`) into format suggested by [Hashicorp](https://github.com/hashicorp/hcl). | [devops-infra](https://github.com/devops-infra/docker-terragrunt/blob/master/fmt/format-hcl)   |
| `terragrunt-fmt.sh` | No                  | Dependency for `format-hcl`                                                                                                        | [cytopia](https://github.com/cytopia/docker-terragrunt-fmt/blob/master/data/terragrunt-fmt.sh) |
| `entrypoint.sh`     | Yes                 | Main CMD target for Docker image, just to show main installed binaries versions.                                                   | [devops-infra](https://github.com/devops-infra/docker-terragrunt/blob/master/entrypoint.sh)    |


### Binaries and Python libraries

| Name                         | Type           | Flavor   | Description                                                                       | Source/Documentation                               |
|------------------------------|----------------|----------|-----------------------------------------------------------------------------------|----------------------------------------------------|
| awscli                       | Binary         | aws      | Interact with AWS via terminal.                                                   | https://github.com/aws/aws-cli                     |
| azure-cli                    | Binary         | azure    | Interact with Azure via terminal.                                                 | https://github.com/Azure/azure-cli                 |
| bc                           | Binary         | non-slim | Numeric operations.                                                               | https://www.gnu.org/software/bc/bc.html            |
| boto3                        | Python library | aws      | Interact with AWS via Python.                                                     | https://github.com/boto/boto3                      |
| cloudflare                   | Python library | non-slim | Cloudflare API operations.                                                        | https://github.com/cloudflare/python-cloudflare    |
| curl                         | Binary         | slim     | HTTP and API calls.                                                               | https://curl.haxx.se/                              |
| docker                       | Binary         | non-slim | Run nested Docker workloads (for example, Lambda packaging workflows).            | https://github.com/docker/docker-ce                |
| git                          | Binary         | slim     | Interact with Git repositories.                                                   | https://git-scm.com/                               |
| go                           | Binary         | non-slim | Build/install additional Go tooling.                                              | https://go.dev/                                    |
| google-cloud-cli             | Binary         | gcp      | Interact with GCP via terminal.                                                   | https://cloud.google.com/sdk                       |
| gnupg                        | Binary         | non-slim | GPG operations (including AWS CLI signature verification).                        | https://gnupg.org/                                 |
| graphviz                     | Binary         | non-slim | Generate graph output, for example from `terraform graph`.                        | https://graphviz.org/                              |
| hcledit                      | Binary         | non-slim | Read/write HCL files.                                                             | https://github.com/minamijoyo/hcledit              |
| gh                           | Binary         | non-slim | Interact with GitHub via official GitHub CLI.                                     | https://cli.github.com/                            |
| hub                          | Binary         | non-slim | Interact with GitHub APIs.                                                        | https://github.com/github/hub                      |
| jq                           | Binary         | slim     | Parse JSON outputs.                                                               | https://stedolan.github.io/jq/                     |
| make                         | Binary         | non-slim | `Makefile`-based task orchestration.                                              | https://www.gnu.org/software/make/                 |
| ncurses (`tput`)             | Binary         | non-slim | Color and terminal helpers used by automation scripts.                            | https://invisible-island.net/ncurses/announce.html |
| openssh-client (`ssh`)       | Binary         | non-slim | Outbound SSH connections.                                                         | https://www.openssh.com/                           |
| openssl                      | Binary         | non-slim | Cryptographic operations and hashing.                                             | https://github.com/openssl/openssl                 |
| opentofu                     | Binary         | slim     | Open-source Terraform alternative for IaC.                                        | https://github.com/opentofu/opentofu               |
| PyGithub                     | Python library | non-slim | Interact with GitHub API in Python.                                               | https://github.com/PyGithub/PyGithub               |
| python-hcl2                  | Python library | non-slim | Parse HCL in Python.                                                              | https://github.com/amplify-education/python-hcl2   |
| python3                      | Binary         | non-slim | Execute Python scripts in automation workflows.                                   | https://www.python.org/                            |
| python-is-python3 (`python`) | Binary         | non-slim | `python` command alias to Python 3.                                               | https://www.python.org/                            |
| python3-pip (`pip3`, `pip`)  | Binary         | non-slim | Python package management.                                                        | https://pip.pypa.io/                               |
| requests                     | Python library | non-slim | HTTP requests from Python.                                                        | https://github.com/psf/requests                    |
| slack_sdk                    | Python library | non-slim | Slack integration in Python.                                                      | https://github.com/slackapi/python-slack-sdk       |
| sops                         | Binary         | non-slim | Encrypt/decrypt secrets used by Terragrunt workflows.                             | https://github.com/getsops/sops                    |
| task                         | Binary         | non-slim | `Taskfile`-based task orchestration (installed via official Task APT repository). | https://taskfile.dev/                              |
| terraform                    | Binary         | slim     | IaC engine used directly and by Terragrunt.                                       | https://github.com/hashicorp/terraform             |
| terragrunt                   | Binary         | slim     | IaC wrapper over Terraform/OpenTofu.                                              | https://github.com/gruntwork-io/terragrunt         |
| tflint                       | Binary         | non-slim | Terraform/OpenTofu linting.                                                       | https://github.com/terraform-linters/tflint        |
| unzip                        | Binary         | slim     | Extract archives during workflows.                                                | http://infozip.sourceforge.net/                    |
| vim                          | Binary         | slim     | Basic editor in container shell sessions.                                         | https://www.vim.org/                               |
| wget                         | Binary         | slim     | Download helper utility.                                                          | https://www.gnu.org/software/wget/                 |
| zip                          | Binary         | non-slim | Create zip artifacts (for example for Lambda packages).                           | http://infozip.sourceforge.net/                    |


# Forking

To publish images from a fork, set these variables so Task uses your registry identities:
`DOCKER_USERNAME`, `DOCKER_ORG_NAME`, `DOCKER_TOKEN`, `GITHUB_USERNAME`, `GITHUB_ORG_NAME`, `GITHUB_TOKEN`.

Two supported options (environment variables take precedence over `.env`):
```bash
# .env (local only, not committed)
DOCKER_USERNAME=your-dockerhub-user
DOCKER_ORG_NAME=your-dockerhub-org
DOCKER_TOKEN=your-docker-token
GITHUB_USERNAME=your-github-user
GITHUB_ORG_NAME=your-github-org
GITHUB_TOKEN=your-github-token
```

```bash
# Shell override
DOCKER_USERNAME=your-dockerhub-user \
  DOCKER_ORG_NAME=your-dockerhub-org \
  DOCKER_TOKEN=your-docker-token \
  GITHUB_USERNAME=your-github-user \
  GITHUB_ORG_NAME=your-github-org \
  GITHUB_TOKEN=your-github-token \
  task docker:build
```

Recommended setup:
- Local development: use a `.env` file.
- GitHub Actions: set repo secrets for `DOCKER_TOKEN` and `GITHUB_TOKEN` and variables for the rest.
- For personal repositories use values for `DOCKER_ORG_NAME` as for `DOCKER_USERNAME`, and the same for Docker.

Publish images without a release:
- Run the `(Manual) Update Version` workflow with `build-and-push-only: true` to build and push images without tagging a release.


## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://shyper.pro/"><img src="https://avatars.githubusercontent.com/u/45788587?v=4?s=100" width="100px;" alt="Krzysztof Szyper"/><br /><sub><b>Krzysztof Szyper</b></sub></a><br /><a href="https://github.com/devops-infra/docker-terragrunt/commits?author=ChristophShyper" title="Code">💻</a> <a href="#maintenance-ChristophShyper" title="Maintenance">🚧</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.everythingcli.org/"><img src="https://avatars.githubusercontent.com/u/12533999?v=4?s=100" width="100px;" alt="cytopia"/><br /><sub><b>cytopia</b></sub></a><br /><a href="https://github.com/devops-infra/docker-terragrunt/commits?author=cytopia" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/markodjukic"><img src="https://avatars.githubusercontent.com/u/12538173?v=4?s=100" width="100px;" alt="Marko Djukic"/><br /><sub><b>Marko Djukic</b></sub></a><br /><a href="https://github.com/devops-infra/docker-terragrunt/commits?author=markodjukic" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://contextflow.com/jobs/"><img src="https://avatars.githubusercontent.com/u/47661139?v=4?s=100" width="100px;" alt="Phileas Lebada"/><br /><sub><b>Phileas Lebada</b></sub></a><br /><a href="#ideas-clushie" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/SmedbergM"><img src="https://avatars.githubusercontent.com/u/3883154?v=4?s=100" width="100px;" alt="Matthew Smedberg"/><br /><sub><b>Matthew Smedberg</b></sub></a><br /><a href="https://github.com/devops-infra/docker-terragrunt/commits?author=SmedbergM" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dsoudakov"><img src="https://avatars.githubusercontent.com/u/14098629?v=4?s=100" width="100px;" alt="Dmitri"/><br /><sub><b>Dmitri</b></sub></a><br /><a href="https://github.com/devops-infra/docker-terragrunt/commits?author=dsoudakov" title="Code">💻</a> <a href="https://github.com/devops-infra/docker-terragrunt/issues?q=author%3Adsoudakov" title="Bug reports">🐛</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/RafaelWO"><img src="https://avatars.githubusercontent.com/u/38643099?v=4?s=100" width="100px;" alt="RafaelWO"/><br /><sub><b>RafaelWO</b></sub></a><br /><a href="https://github.com/devops-infra/docker-terragrunt/commits?author=RafaelWO" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification.
Contributions of any kind welcome!
