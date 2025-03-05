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
ARG AWS_VERSION=latest
ARG GCP_VERSION
ARG AZ_VERSION
ARG TF_VERSION=none
ARG OT_VERSION=none
ARG TG_VERSION=latest

# List of Python packages
COPY pip/common/requirements.txt /tmp/pip_common_requirements.txt
COPY pip/aws/requirements.txt /tmp/pip_aws_requirements.txt
COPY pip/yc/requirements.txt /tmp/pip_yc_requirements.txt

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
RUN for i in {1..5}; do \
    apt-get update -y && break ;\
    echo "Retrying install in 15 seconds..." ;\
    sleep 15 ;\
  done ;\
  echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections ;\
  echo "Installing apt packages" ;\
  for i in {1..5}; do \
    apt-get install --no-install-recommends -y \
      ca-certificates \
      curl \
      git \
      jq \
      vim \
      wget \
      unzip && break ;\
    echo "Retrying install in 15 seconds for basic binaries..." ;\
    sleep 15 ;\
  done ;\
  for i in {1..5}; do \
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
        python3-pip \
        zip ;\
      pip3 install --no-cache-dir -r /tmp/pip_common_requirements.txt --break-system-packages ;\
    fi && break ;\
    echo "Retrying install in 15 seconds for slim binaries..." ;\
    sleep 15 ;\
  done

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
    echo "Installing Terraform" ;\
    if [ "${TF_VERSION}" = "latest" ]; then \
      VERSION="$(curl -sL https://releases.hashicorp.com/terraform/ | tac | tac | grep -Eo '/[.0-9]+/' | grep -Eo '[.0-9]+' | sort -V | tail -1)" ;\
    else \
      VERSION="${TF_VERSION}" ;\
    fi ;\
    DOWNLOAD_URL="https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_${ARCHITECTURE}.zip" ;\
    if [ -z "${DOWNLOAD_URL}" ]; then \
      echo "Empty download URL for Terraform" ;\
      exit 1 ;\
    fi ;\
    CHECK_URL="$(curl -Is "${DOWNLOAD_URL}" | tac | tac | head -1 | grep -Eo "200|301|302")" ;\
    if [ -z "${CHECK_URL}" ]; then \
      echo "Invalid URL for Terraform: ${DOWNLOAD_URL}" ;\
      exit 1 ;\
    fi ;\
    for i in {1..5}; do \
      curl -sL "${DOWNLOAD_URL}" -o ./terraform.zip && break ;\
      echo "Retrying download for Terraform in 15 seconds..." ;\
      sleep 15 ;\
    done ;\
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
    echo "No OpenTofu version specified ..." ;\
  else \
    echo "Installing OpenTofu" ;\
    if [ "${OT_VERSION}" = "latest" ]; then \
      VERSION="$(curl -sL https://api.github.com/repos/opentofu/opentofu/releases/latest | tac | tac | jq -r .tag_name | sed 's/^v//')" ;\
    else \
      VERSION="${OT_VERSION}" ;\
    fi ;\
    DOWNLOAD_URL="https://github.com/opentofu/opentofu/releases/download/v${VERSION}/tofu_${VERSION}_${ARCHITECTURE}.deb" ;\
    if [ -z "${DOWNLOAD_URL}" ]; then \
      echo "Empty download URL for OpenTofu" ;\
      exit 1 ;\
    fi ;\
    CHECK_URL="$(curl -Is "${DOWNLOAD_URL}" | tac | tac | head -1 | grep -Eo "200|301|302")" ;\
    if [ -z "${CHECK_URL}" ]; then \
      echo "Invalid URL for Terragrunt: ${DOWNLOAD_URL}" ;\
      exit 1 ;\
    fi ;\
    for i in {1..5}; do  \
      curl -sL "${DOWNLOAD_URL}" -o ./tofu.deb && break ;\
      echo "Retrying download for OpenTofu in 15 seconds..." ;\
      sleep 15 ;\
    done ;\
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
  echo "Installing Terragrunt" ;\
  if [ "${TG_VERSION}" = "latest" ]; then \
    VERSION="$(curl -sL https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | tac | tac | jq -r .name)" ;\
  else \
    VERSION="v${TG_VERSION}" ;\
  fi ;\
  DOWNLOAD_URL="https://github.com/gruntwork-io/terragrunt/releases/download/${VERSION}/terragrunt_linux_${ARCHITECTURE}" ;\
  if [ -z "${DOWNLOAD_URL}" ]; then \
    echo "Empty download URL for Terragrunt" ;\
    exit 1 ;\
  fi ;\
  CHECK_URL="$(curl -Is "${DOWNLOAD_URL}" | tac | tac | head -1 | grep -Eo "200|301|302")" ;\
  if [ -z "${CHECK_URL}" ]; then \
    echo "Invalid URL for Terragrunt: ${DOWNLOAD_URL}" ;\
    exit 1 ;\
  else \
    echo "Using URL: ${DOWNLOAD_URL}" ;\
  fi ;\
  for i in {1..5}; do \
    curl -sL "${DOWNLOAD_URL}" -o /usr/bin/terragrunt && break ;\
    echo "Retrying download for Terragrunt in 15 seconds..." ;\
    sleep 15 ;\
  done ;\
  chmod +x /usr/bin/terragrunt

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
  DOWNLOAD_URL="$(curl -sL https://api.github.com/repos/terraform-linters/tflint/releases/latest | tac | tac | grep -Eo "https://.+?_linux_${ARCHITECTURE}.zip")" ;\
  if [ -z "${DOWNLOAD_URL}" ]; then \
    echo "Empty download URL for TFLint" ;\
    exit 1 ;\
  fi ;\
  CHECK_URL="$(curl -Is "${DOWNLOAD_URL}" | tac | tac | head -1 | grep -Eo "200|301|302")" ;\
  if [ -z "${CHECK_URL}" ]; then \
    echo "Invalid URL for TFLint: ${DOWNLOAD_URL}" ;\
    exit 1 ;\
  fi ;\
  for i in {1..5}; do \
    curl -sL "${DOWNLOAD_URL}" -o ./tflint.zip && break ;\
    echo "Retrying download for TFLint in 15 seconds..." ;\
    sleep 15 ;\
  done ;\
  unzip ./tflint.zip ;\
  rm -f ./tflint.zip ;\
  chmod +x ./tflint ;\
  mv ./tflint /usr/bin/tflint

# Get latest hcledit
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=SC2015,SC2034
RUN if [ "${SLIM}" = "no" ]; then \
    echo "Installing hcledit" ;\
    if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
      ARCHITECTURE=amd64 ;\
    elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
      ARCHITECTURE=arm64 ;\
    else \
      echo "Unsupported architecture: ${TARGETPLATFORM}" ;\
      exit 1 ;\
    fi ;\
    DOWNLOAD_URL="$(curl -sL https://api.github.com/repos/minamijoyo/hcledit/releases/latest | tac | tac | grep -Eo "https://.+?_linux_${ARCHITECTURE}.tar.gz")" ;\
    if [ -z "${DOWNLOAD_URL}" ]; then \
      echo "Empty download URL for hcledit" ;\
      exit 1; \
    fi ;\
    CHECK_URL="$(curl -Is "${DOWNLOAD_URL}" | tac | tac | head -1 | grep -Eo "200|301|302")" ;\
    if [ -z "${CHECK_URL}" ]; then \
      echo "Invalid URL for hcledit: ${DOWNLOAD_URL}" ;\
      exit 1 ;\
    fi ;\
    for i in {1..5}; do \
      curl -sL "${DOWNLOAD_URL}" -o ./hcledit.tar.gz && break ;\
      echo "Retrying download for hcledit in 15 seconds..." ;\
      sleep 15 ;\
    done ;\
    tar -xf ./hcledit.tar.gz ;\
    rm -f ./hcledit.tar.gz ;\
    chmod +x ./hcledit ;\
    chown "$(id -u):$(id -g)" ./hcledit ;\
    mv ./hcledit /usr/bin/hcledit ;\
  fi

# Get latest sops
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=SC2015,SC2034
RUN if [ "${SLIM}" = "no" ]; then \
    echo "Installing sops" ;\
    if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
      ARCHITECTURE=amd64 ;\
    elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
      ARCHITECTURE=arm64 ;\
    else \
      echo "Unsupported architecture: ${TARGETPLATFORM}" ;\
      exit 1 ;\
    fi ;\
    DOWNLOAD_URL="$(curl -sL https://api.github.com/repos/getsops/sops/releases/latest | tac | tac | grep -Eo "https://.+?\.linux.${ARCHITECTURE}" | head -1)" ;\
    if [ -z "${DOWNLOAD_URL}" ]; then \
      echo "Empty download URL for sops" ;\
      exit 1; \
    fi ;\
    CHECK_URL="$(curl -Is "${DOWNLOAD_URL}" | tac | tac | head -1 | grep -Eo "200|301|302")" ;\
    if [ -z "${CHECK_URL}" ]; then \
      echo "Invalid URL for sops: ${DOWNLOAD_URL}" ;\
      exit 1 ;\
    fi ;\
    for i in {1..5}; do \
      curl -sL "${DOWNLOAD_URL}" -o /usr/bin/sops && break ;\
      echo "Retrying download for sops in 15 seconds..." ;\
      sleep 15 ;\
    done ;\
    chmod +x /usr/bin/sops ;\
  fi

# Cloud CLIs
# AWS
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=DL3013,SC2015,SC2034
RUN if [ "${AWS}" = "yes" ]; then \
    echo "Installing AWS CLI" ;\
    xargs -n 1 -a /tmp/pip_aws_requirements.txt pip3 install --no-cache-dir --break-system-packages ;\
    if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
      ARCHITECTURE=x86_64 ;\
    elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
      ARCHITECTURE=aarch64 ;\
    else \
      echo "Unsupported architecture: ${TARGETPLATFORM}" ;\
      exit 1 ;\
    fi ;\
    if [ "${AWS_VERSION}" = "latest" ]; then VERSION=""; else VERSION="-${AWS_VERSION}"; fi ;\
    DOWNLOAD_URL="https://awscli.amazonaws.com/awscli-exe-linux-${ARCHITECTURE}${VERSION}.zip" ;\
    if [ -z "${DOWNLOAD_URL}" ]; then \
      echo "Empty download URL for AWS CLI" ;\
      exit 1; \
    fi ;\
    CHECK_URL="$(curl -Is "${DOWNLOAD_URL}" | tac | tac | head -1 | grep -Eo "200|301|302")" ;\
    if [ -z "${CHECK_URL}" ]; then \
      echo "Invalid URL for AWS CLI: ${DOWNLOAD_URL}" ;\
      exit 1 ;\
    fi ;\
    for i in {1..5}; do \
      curl -sL "${DOWNLOAD_URL}" -o /tmp/awscli.zip && break ;\
      echo "Retrying download for AWS CLI in 15 seconds..." ;\
      sleep 15 ;\
    done ;\
    mkdir -p /usr/local/awscli ;\
    unzip -q /tmp/awscli.zip -d /usr/local/awscli ;\
    /usr/local/awscli/aws/install ;\
  fi

# GCP
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=SC1091,SC2015,SC2129
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
    if [ -z "${DOWNLOAD_URL}" ]; then \
      echo "Empty download URL for Google Cloud SDK" ;\
      exit 1; \
    fi ;\
    CHECK_URL="$(curl -Is "${DOWNLOAD_URL}" | tac | tac | head -1 | grep -Eo "200|301|302")" ;\
    if [ -z "${CHECK_URL}" ]; then \
      echo "Invalid URL for Google Cloud SDK: ${DOWNLOAD_URL}" ;\
      exit 1 ;\
    fi ;\
    for i in {1..5}; do  \
      curl -sL "${DOWNLOAD_URL}" -o google-cloud-sdk.tar.gz && break ;\
      echo "Retrying download for Google Cloud SDK in 15 seconds..." ;\
      sleep 15 ;\
    done ;\
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
# hadolint ignore=DL3009,DL4001
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

# YandexCloud
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=DL3013,SC2015,DL4001,SC2034
RUN if [ "${YC}" = "yes" ]; then \
    echo "Installing Yandex Cloud CLI" ;\
    xargs -n 1 -a /tmp/pip_yc_requirements.txt pip3 install --no-cache-dir --break-system-packages ;\
    for i in {1..5}; do curl -sL "https://storage.yandexcloud.net/yandexcloud-yc/install.sh" | bash -s -- -a -i /opt/yc -r /etc/bash.bashrc && break ;\
    echo "Retrying Install in 15 seconds..." ;\
    sleep 15; done ;\
    ln -s /opt/yc/bin/yc /usr/bin/yc ;\
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
