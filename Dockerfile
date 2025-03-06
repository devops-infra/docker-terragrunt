FROM ubuntu:24.04

# Disable interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Multi-architecture from buildx
ARG TARGETPLATFORM

# Which flavour of image to build
ARG SLIM=no
ARG AZURE=no
ARG AWS=no
ARG GCP=no
ARG YC=no

# Versions of dependecies, GCP has no default handler
ARG AWS_VERSION
ARG GCP_VERSION
ARG AZ_VERSION
ARG TF_VERSION=none
ARG OT_VERSION=none
ARG TG_VERSION=none

# List of Python packages
COPY pip/common/requirements.txt /tmp/pip_common_requirements.txt
COPY pip/aws/requirements.txt /tmp/pip_aws_requirements.txt

# Debug information
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=DL3008,SC2015,SC2129
RUN echo Debug information: ;\
  echo TARGETPLATFORM = "${TARGETPLATFORM}" ;\
  if [ "${AWS}" == "yes" ]; then echo AWS_VERSION = "${AWS_VERSION}"; fi ;\
  if [ "${GCP}" == "yes" ]; then echo GCP_VERSION = "${GCP_VERSION}"; fi ;\
  if [ "${AZURE}" == "yes" ]; then echo AZ_VERSION = "${AZ_VERSION}"; fi ;\
  echo TF_VERSION = "${TF_VERSION}" ;\
  echo OT_VERSION = "${OT_VERSION}" ;\
  echo TG_VERSION = "${TG_VERSION}" ;\
  echo 'path-exclude /usr/share/doc/*' > /etc/dpkg/dpkg.cfg.d/docker-minimal ;\
  echo 'path-exclude /usr/share/man/*' >> /etc/dpkg/dpkg.cfg.d/docker-minimal ;\
  echo 'path-exclude /usr/share/groff/*' >> /etc/dpkg/dpkg.cfg.d/docker-minimal ;\
  echo 'path-exclude /usr/share/info/*' >> /etc/dpkg/dpkg.cfg.d/docker-minimal ;\
  echo 'path-exclude /usr/share/lintian/*' >> /etc/dpkg/dpkg.cfg.d/docker-minimal ;\
  echo 'path-exclude /usr/share/linda/*' >> /etc/dpkg/dpkg.cfg.d/docker-minimal ;\
  echo 'path-exclude /usr/share/locale/*' >> /etc/dpkg/dpkg.cfg.d/docker-minimal

# Install apt prerequisits, retry since ubuntu archive is failing a lot
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=DL3008,SC2015,DL3009,SC2034
RUN apt-get update -y ;\
  echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections ;\
  echo "Installing apt packages" ;\
  apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
    git \
    jq \
    vim \
    wget \
    unzip ;\
  if [ "${SLIM}" = "no" ]; then \
    apt-get install --no-install-recommends -y \
      apt-transport-https \
      bc \
      docker.io \
      gnupg \
      golang-go \
      graphviz \
      hub \
      lsb-release \
      make \
      ncurses-base \
      openssh-client \
      openssl \
      python3 \
      python-is-python3 \
      python3-pip \
      zip ;\
    pip3 install --no-cache-dir -r /tmp/pip_common_requirements.txt --break-system-packages ;\
  fi

# Get Terraform by a specific version or search for the latest one
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=SC2015,SC2034
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
    ARCHITECTURE=amd64 ;\
  elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
    ARCHITECTURE=arm64 ;\
  else \
    echo "Unsupported architecture: ${TARGETPLATFORM}" ;\
    exit 1 ;\
  fi ;\
  if [ "${TF_VERSION}" = "none" ]; then \
    echo "No Terraform version specified..." ;\
  else \
    echo "Installing Terraform v${TF_VERSION}" ;\
    DOWNLOAD_URL="https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${ARCHITECTURE}.zip" ;\
    curl -sL "${DOWNLOAD_URL}" -o ./terraform.zip ;\
    unzip ./terraform.zip ;\
    rm -f ./terraform.zip ;\
    chmod +x ./terraform ;\
    mv ./terraform /usr/bin/terraform ;\
  fi

# Get OpenTofu by a specific version or search for the latest one
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=SC2015,SC2034
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
    ARCHITECTURE=amd64 ;\
  elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
    ARCHITECTURE=arm64 ;\
  else \
    echo "Unsupported architecture: ${TARGETPLATFORM}" ;\
    exit 1 ;\
  fi ;\
  if [ "${OT_VERSION}" = "none" ]; then \
    echo "No OpenTofu version specified..." ;\
  else \
    echo "Installing OpenTofu v${OT_VERSION}" ;\
    DOWNLOAD_URL="https://github.com/opentofu/opentofu/releases/download/v${OT_VERSION}/tofu_${OT_VERSION}_${ARCHITECTURE}.deb" ;\
    curl -sL "${DOWNLOAD_URL}" -o ./tofu.deb ;\
    dpkg -i ./tofu.deb ;\
    rm -f ./tofu.deb ;\
  fi

# Get Terragrunt by a specific version or search for the latest one
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=SC2015,SC2034
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
    ARCHITECTURE=amd64 ;\
  elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
    ARCHITECTURE=arm64 ;\
  else \
    echo "Unsupported architecture: ${TARGETPLATFORM}" ;\
    exit 1 ;\
  fi ;\
  if [ "${TG_VERSION}" = "none" ]; then \
    echo "No Terragrunt version specified..." ;\
    exit 1 ;\
  else \
    echo "Installing Terragrunt v${TG_VERSION}" ;\
    DOWNLOAD_URL="https://github.com/gruntwork-io/terragrunt/releases/download/v${TG_VERSION}/terragrunt_linux_${ARCHITECTURE}" ;\
    curl -sL "${DOWNLOAD_URL}" -o /usr/bin/terragrunt ;\
    chmod +x /usr/bin/terragrunt ;\
  fi

# Get latest TFLint
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=SC2015,SC2034
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
    ARCHITECTURE=amd64 ;\
  elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
    ARCHITECTURE=arm64 ;\
  else \
    echo "Unsupported architecture: ${TARGETPLATFORM}" ;\
    exit 1 ;\
  fi ;\
  echo "Installing TFLint" ;\
  DOWNLOAD_URL="$(curl -sL https://api.github.com/repos/terraform-linters/tflint/releases/latest | jq -r ".assets[] | select(.name | endswith(\"linux_${ARCHITECTURE}.zip\")) | .browser_download_url")" ;\
  if [ -z "${DOWNLOAD_URL}" ]; then \
    echo "Empty download URL for TFLint" ;\
    exit 1 ;\
  fi ;\
  curl -sL "${DOWNLOAD_URL}" -o ./tflint.zip ;\
  unzip ./tflint.zip ;\
  rm -f ./tflint.zip ;\
  chmod +x ./tflint ;\
  mv ./tflint /usr/bin/tflint

# Get latest hcledit
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=SC2015,SC2034
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
    ARCHITECTURE=amd64 ;\
  elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
    ARCHITECTURE=arm64 ;\
  else \
    echo "Unsupported architecture: ${TARGETPLATFORM}" ;\
    exit 1 ;\
  fi ;\
  echo "Installing hcledit" ;\
  DOWNLOAD_URL="$(curl -sL https://api.github.com/repos/minamijoyo/hcledit/releases/latest | jq -r ".assets[] | select(.name | endswith(\"linux_${ARCHITECTURE}.tar.gz\")) | .browser_download_url")" ;\
  if [ -z "${DOWNLOAD_URL}" ]; then \
    echo "Empty download URL for hcledit" ;\
    exit 1 ;\
  fi ;\
  curl -sL "${DOWNLOAD_URL}" -o ./hcledit.tar.gz ;\
  tar -xf ./hcledit.tar.gz ;\
  rm -f ./hcledit.tar.gz ;\
  chmod +x ./hcledit ;\
  chown "$(id -u):$(id -g)" ./hcledit ;\
  mv ./hcledit /usr/bin/hcledit

# Get latest sops
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=SC2015,SC2034
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
    ARCHITECTURE=amd64 ;\
  elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
    ARCHITECTURE=arm64 ;\
  else \
    echo "Unsupported architecture: ${TARGETPLATFORM}" ;\
    exit 1 ;\
  fi ;\
  echo "Installing sops" ;\
  DOWNLOAD_URL="$(curl -sL https://api.github.com/repos/getsops/sops/releases/latest | jq -r ".assets[] | select(.name | endswith(\"linux.${ARCHITECTURE}\")) | .browser_download_url")" ;\
  if [ -z "${DOWNLOAD_URL}" ]; then \
    echo "Empty download URL for sops" ;\
    exit 1 ;\
  fi ;\
  curl -sL "${DOWNLOAD_URL}" -o /usr/bin/sops ;\
  chmod +x /usr/bin/sops

# Cloud CLIs

# AWS
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=DL3013,SC2015,SC2034
RUN if [ "${AWS}" = "yes" ]; then \
    echo "Installing AWS CLI" ;\
    if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
      ARCHITECTURE=x86_64 ;\
    elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
      ARCHITECTURE=aarch64 ;\
    else \
      echo "Unsupported architecture: ${TARGETPLATFORM}" ;\
      exit 1 ;\
    fi ;\
    xargs -n 1 -a /tmp/pip_aws_requirements.txt pip3 install --no-cache-dir --break-system-packages ;\
    DOWNLOAD_URL="https://awscli.amazonaws.com/awscli-exe-linux-${ARCHITECTURE}-${AWS_VERSION}.zip" ;\
    curl -sL "${DOWNLOAD_URL}" -o /tmp/awscli.zip ;\
    mkdir -p /usr/local/awscli ;\
    unzip -q /tmp/awscli.zip -d /usr/local/awscli ;\
    /usr/local/awscli/aws/install ;\
  fi

# GCP
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=SC1091,SC2015,SC2129,SC2034
RUN if [ "${GCP}" = "yes" ]; then \
    echo "Installing Google Cloud SDK" ;\
    if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
      ARCHITECTURE=x86_64 ;\
    elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
      ARCHITECTURE=arm ;\
    else \
      echo "Unsupported architecture: ${TARGETPLATFORM}" ;\
      exit 1 ;\
    fi ;\
    DOWNLOAD_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCP_VERSION}-linux-${ARCHITECTURE}.tar.gz" ;\
    curl -sL "${DOWNLOAD_URL}" -o google-cloud-sdk.tar.gz ;\
    tar -xf google-cloud-sdk.tar.gz ;\
    rm -f google-cloud-sdk.tar.gz ;\
    ./google-cloud-sdk/install.sh \
      --usage-reporting false \
      --command-completion true \
      --path-update true \
      --quiet ;\
    /google-cloud-sdk/bin/gcloud config set component_manager/disable_update_check true ;\
    /google-cloud-sdk/bin/gcloud config set metrics/environment github_docker_image ;\
    echo -e "\n# Add Google Cloud SDK" >> /etc/bash.bashrc ;\
    echo "source /google-cloud-sdk/path.bash.inc" >> /etc/bash.bashrc ;\
    echo "source /google-cloud-sdk/completion.bash.inc" >> /etc/bash.bashrc ;\
  fi

ENV PATH="$PATH:/google-cloud-sdk/bin"

# Azure
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# using wget to bypass curl error for arm64 https://bugs.launchpad.net/ubuntu/+source/curl/+bug/2073448
# hadolint ignore=DL3009,DL4001,SC2034
RUN if [ "${AZURE}" = "yes" ]; then \
    echo "Installing Azure CLI" ;\
    mkdir -p /etc/apt/keyrings ;\
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/keyrings/microsoft.gpg > /dev/null ;\
    chmod go+r /etc/apt/keyrings/microsoft.gpg ;\
    AZ_DIST=$(lsb_release -cs) ;\
    printf "Types: deb\n\
URIs: https://packages.microsoft.com/repos/azure-cli/\n\
Suites: %s\n\
Components: main\n\
Architectures: %s\n\
Signed-by: /etc/apt/keyrings/microsoft.gpg" "$AZ_DIST" "$(dpkg --print-architecture)" | tee /etc/apt/sources.list.d/azure-cli.sources ;\
    apt-get update -y ;\
    apt-get install --no-install-recommends -y azure-cli="${AZ_VERSION}-1~${AZ_DIST}" ;\
  fi

# Scripts, configs and cleanup
COPY fmt/format-hcl fmt/fmt.sh fmt/terragrunt-fmt.sh show-versions.sh /usr/bin/
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN chmod +x \
    /usr/bin/format-hcl \
    /usr/bin/fmt.sh \
    /usr/bin/terragrunt-fmt.sh \
    /usr/bin/show-versions.sh ;\
  apt-get clean ;\
  rm -rf /var/lib/apt/lists/* ;\
  rm -rf /var/cache/* ;\
  rm -rf /root/.cache/* ;\
  rm -rf /tmp/*

WORKDIR /data
CMD ["show-versions.sh"]
