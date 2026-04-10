FROM ubuntu:noble-20260217

# Disable interactive mode
ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Multi-architecture from buildx
ARG TARGETARCH

# Which flavour of image to build
ARG SLIM=no
ARG AZURE=no
ARG AWS=no
ARG GCP=no
ARG YC=no

# Versions of dependencies, GCP has no default handler
ARG AWS_VERSION
ARG GCP_VERSION
ARG AZ_VERSION
ARG TF_VERSION=none
ARG OT_VERSION=none
ARG TG_VERSION=none

# Pinned tool versions (override via --build-arg if needed)
ARG TFLINT_VERSION=0.59.1
ARG HCLEDIT_VERSION=0.2.17
ARG SOPS_VERSION=3.10.2
ARG TASK_VERSION=3.45.4

# Artifact checksums for deterministic, verified downloads
ARG TF_SHA256_AMD64=56a5d12f47cbc1c6bedb8f5426ae7d5df984d1929572c24b56f4c82e9f9bf709
ARG TF_SHA256_ARM64=c953171cde6b25ca0448c3b29a90d2f46c0310121e18742ec8f89631768e770c
ARG OT_DEB_SHA256_AMD64=6453ce40a165e174971b0214f1d190861fcec1e22bf930504d06747474503c1e
ARG OT_DEB_SHA256_ARM64=f43917a89f76a68e629133463c027ad25ecbf310378e456033b1839bd841d8f4
ARG TG_SHA256_AMD64=98bffc93e6f8a07809842cd402f2b66b2935139911e7c513d38425a352c777b2
ARG TG_SHA256_ARM64=e4c80367ed82fe2b79dc9a865e82fcaa6be225dd8b1895eb386df2b5f9f4320d
ARG TFLINT_SHA256_AMD64=6108d84282292f11d793dc8038ce08fbc629dcd25324d6f13c63d8100b52e01f
ARG TFLINT_SHA256_ARM64=426f998f9cbd0d738164ed0fb52e9ee268139dc52d8622c8c7a40afbea2c2811
ARG HCLEDIT_SHA256_AMD64=5e085bd319c84c74e87b915ab2c1f95afccb2d4326be481fbe19c1d7a0eb5fee
ARG HCLEDIT_SHA256_ARM64=a1d052a5bbfd4c97c82946bd40097f61b5e7dbf7e43d39d52950633487b7bec4
ARG SOPS_SHA256_AMD64=79b0f844237bd4b0446e4dc884dbc1765fc7dedc3968f743d5949c6f2e701739
ARG SOPS_SHA256_ARM64=e91ddc04e6a78f5aed9e4fc347a279b539c43b74d99e6b8078e2f2f6f5b309f5
ARG TASK_SHA256_AMD64=4e7d24f1bf38218aec8f244eb7ba671f898830f9f87b3c9b30ff1c09e3135576
ARG TASK_SHA256_ARM64=aa6732c9c66397c5380ec2b60c070fd599075b2a8538dba03f3a21edc99ab0cb
ARG AWSCLI_SHA256_X86_64=cbc6978c4126440db18df7154db6ca2f5327f5282325d196e9faa9f7a3898bb4
ARG AWSCLI_SHA256_AARCH64=5818d17ce4973ebe99618ed0dcb37c7884260f98f688fdd9850cadd64a9bce4b
ARG GCP_SHA256_X86_64=2cde419f91fa3f62edbd18841ecadac070772c52ec1ebaac99987412bd66cd01
ARG GCP_SHA256_ARM=c503d48fb346c67ba7b9e03dfb520371e189eabc79ff2cb85fcc018b1670d8e6

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Debug information
# hadolint ignore=DL3008,SC2015,SC2129
RUN echo Debug information: ;\
  echo TARGETARCH = "${TARGETARCH}" ;\
  if [ "${AWS}" = "yes" ]; then echo AWS_VERSION = "${AWS_VERSION}"; fi ;\
  if [ "${GCP}" = "yes" ]; then echo GCP_VERSION = "${GCP_VERSION}"; fi ;\
  if [ "${AZURE}" = "yes" ]; then echo AZ_VERSION = "${AZ_VERSION}"; fi ;\
  echo TF_VERSION = "${TF_VERSION}" ;\
  echo OT_VERSION = "${OT_VERSION}" ;\
  echo TG_VERSION = "${TG_VERSION}" ;\
  echo TFLINT_VERSION = "${TFLINT_VERSION}" ;\
  echo HCLEDIT_VERSION = "${HCLEDIT_VERSION}" ;\
  echo SOPS_VERSION = "${SOPS_VERSION}" ;\
  echo TASK_VERSION = "${TASK_VERSION}" ;\
  case "${TARGETARCH}" in amd64|arm64) ;; *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; esac ;\
  echo 'path-exclude /usr/share/doc/*' > /etc/dpkg/dpkg.cfg.d/docker-minimal ;\
  echo 'path-exclude /usr/share/man/*' >> /etc/dpkg/dpkg.cfg.d/docker-minimal ;\
  echo 'path-exclude /usr/share/groff/*' >> /etc/dpkg/dpkg.cfg.d/docker-minimal ;\
  echo 'path-exclude /usr/share/info/*' >> /etc/dpkg/dpkg.cfg.d/docker-minimal ;\
  echo 'path-exclude /usr/share/lintian/*' >> /etc/dpkg/dpkg.cfg.d/docker-minimal ;\
  echo 'path-exclude /usr/share/linda/*' >> /etc/dpkg/dpkg.cfg.d/docker-minimal ;\
  echo 'path-exclude /usr/share/locale/*' >> /etc/dpkg/dpkg.cfg.d/docker-minimal

# Install apt prerequisites and clean apt metadata in the same layer
# hadolint ignore=DL3008,DL3009
RUN apt-get update -y ;\
  echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections ;\
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
  fi ;\
  apt-get clean ;\
  rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Keep requirements copy right before pip install for better cache reuse
COPY pip/common/requirements.txt /tmp/pip_common_requirements.txt
RUN if [ "${SLIM}" = "no" ]; then \
    pip3 install --no-cache-dir -r /tmp/pip_common_requirements.txt ;\
  fi ;\
  rm -f /tmp/pip_common_requirements.txt

# Install Terraform/OpenTofu/Terragrunt in one layer
# hadolint ignore=SC2155
RUN case "${TARGETARCH}" in amd64|arm64) ARCHITECTURE="${TARGETARCH}" ;; *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; esac ;\
  case "${ARCHITECTURE}" in \
    amd64) TF_SHA256="${TF_SHA256_AMD64}"; OT_DEB_SHA256="${OT_DEB_SHA256_AMD64}"; TG_SHA256="${TG_SHA256_AMD64}" ;; \
    arm64) TF_SHA256="${TF_SHA256_ARM64}"; OT_DEB_SHA256="${OT_DEB_SHA256_ARM64}"; TG_SHA256="${TG_SHA256_ARM64}" ;; \
  esac ;\
  TMP_DIR="$(mktemp -d)" ;\
  install_zip_binary() { \
    local url="$1" ;\
    local binary_name="$2" ;\
    local sha256="$3" ;\
    local zip_path="${TMP_DIR}/${binary_name}.zip" ;\
    curl -fsSL "${url}" -o "${zip_path}" ;\
    echo "${sha256}  ${zip_path}" | sha256sum -c - ;\
    unzip -q "${zip_path}" -d "${TMP_DIR}" ;\
    chmod +x "${TMP_DIR}/${binary_name}" ;\
    mv "${TMP_DIR}/${binary_name}" "/usr/bin/${binary_name}" ;\
  } ;\
  if [ "${TF_VERSION}" != "none" ]; then \
    install_zip_binary "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${ARCHITECTURE}.zip" terraform "${TF_SHA256}" ;\
  else \
    echo "No Terraform version specified..." ;\
  fi ;\
  if [ "${OT_VERSION}" != "none" ]; then \
    curl -fsSL "https://github.com/opentofu/opentofu/releases/download/v${OT_VERSION}/tofu_${OT_VERSION}_${ARCHITECTURE}.deb" -o "${TMP_DIR}/tofu.deb" ;\
    echo "${OT_DEB_SHA256}  ${TMP_DIR}/tofu.deb" | sha256sum -c - ;\
    dpkg -i "${TMP_DIR}/tofu.deb" ;\
  else \
    echo "No OpenTofu version specified..." ;\
  fi ;\
  if [ "${TG_VERSION}" = "none" ]; then \
    echo "No Terragrunt version specified..." ;\
    exit 1 ;\
  fi ;\
  curl -fsSL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TG_VERSION}/terragrunt_linux_${ARCHITECTURE}" -o /usr/bin/terragrunt ;\
  echo "${TG_SHA256}  /usr/bin/terragrunt" | sha256sum -c - ;\
  chmod +x /usr/bin/terragrunt ;\
  rm -rf "${TMP_DIR}"

# Install helper binaries in a dedicated layer for better cache locality
RUN case "${TARGETARCH}" in amd64|arm64) ARCHITECTURE="${TARGETARCH}" ;; *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; esac ;\
  case "${ARCHITECTURE}" in \
    amd64) TFLINT_SHA256="${TFLINT_SHA256_AMD64}"; HCLEDIT_SHA256="${HCLEDIT_SHA256_AMD64}"; SOPS_SHA256="${SOPS_SHA256_AMD64}"; TASK_SHA256="${TASK_SHA256_AMD64}" ;; \
    arm64) TFLINT_SHA256="${TFLINT_SHA256_ARM64}"; HCLEDIT_SHA256="${HCLEDIT_SHA256_ARM64}"; SOPS_SHA256="${SOPS_SHA256_ARM64}"; TASK_SHA256="${TASK_SHA256_ARM64}" ;; \
  esac ;\
  TMP_DIR="$(mktemp -d)" ;\
  install_zip_binary() { \
    local url="$1" ;\
    local binary_name="$2" ;\
    local sha256="$3" ;\
    local zip_path="${TMP_DIR}/${binary_name}.zip" ;\
    curl -fsSL "${url}" -o "${zip_path}" ;\
    echo "${sha256}  ${zip_path}" | sha256sum -c - ;\
    unzip -q "${zip_path}" -d "${TMP_DIR}" ;\
    chmod +x "${TMP_DIR}/${binary_name}" ;\
    mv "${TMP_DIR}/${binary_name}" "/usr/bin/${binary_name}" ;\
  } ;\
  install_zip_binary "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${ARCHITECTURE}.zip" tflint "${TFLINT_SHA256}" ;\
  curl -fsSL "https://github.com/minamijoyo/hcledit/releases/download/v${HCLEDIT_VERSION}/hcledit_${HCLEDIT_VERSION}_linux_${ARCHITECTURE}.tar.gz" -o "${TMP_DIR}/hcledit.tar.gz" ;\
  echo "${HCLEDIT_SHA256}  ${TMP_DIR}/hcledit.tar.gz" | sha256sum -c - ;\
  tar -xf "${TMP_DIR}/hcledit.tar.gz" -C "${TMP_DIR}" ;\
  chmod +x "${TMP_DIR}/hcledit" ;\
  mv "${TMP_DIR}/hcledit" /usr/bin/hcledit ;\
  curl -fsSL "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${ARCHITECTURE}" -o /usr/bin/sops ;\
  echo "${SOPS_SHA256}  /usr/bin/sops" | sha256sum -c - ;\
  chmod +x /usr/bin/sops ;\
  if [ "${SLIM}" = "no" ]; then \
    curl -fsSL "https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_linux_${ARCHITECTURE}.tar.gz" -o "${TMP_DIR}/task.tar.gz" ;\
    echo "${TASK_SHA256}  ${TMP_DIR}/task.tar.gz" | sha256sum -c - ;\
    tar -xf "${TMP_DIR}/task.tar.gz" -C "${TMP_DIR}" task ;\
    chmod +x "${TMP_DIR}/task" ;\
    mv "${TMP_DIR}/task" /usr/bin/task ;\
  fi ;\
  rm -rf "${TMP_DIR}"

# Cloud CLIs

# AWS
COPY pip/aws/requirements.txt /tmp/pip_aws_requirements.txt
# hadolint ignore=DL3013
RUN if [ "${AWS}" = "yes" ]; then \
    case "${TARGETARCH}" in \
      amd64) AWS_ARCHITECTURE=x86_64; AWSCLI_SHA256="${AWSCLI_SHA256_X86_64}" ;; \
      arm64) AWS_ARCHITECTURE=aarch64; AWSCLI_SHA256="${AWSCLI_SHA256_AARCH64}" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac ;\
    xargs -n 1 -a /tmp/pip_aws_requirements.txt pip3 install --no-cache-dir ;\
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCHITECTURE}-${AWS_VERSION}.zip" -o /tmp/awscli.zip ;\
    echo "${AWSCLI_SHA256}  /tmp/awscli.zip" | sha256sum -c - ;\
    mkdir -p /tmp/awscli ;\
    unzip -q /tmp/awscli.zip -d /tmp/awscli ;\
    /tmp/awscli/aws/install ;\
    rm -rf /tmp/awscli /tmp/awscli.zip ;\
  fi ;\
  rm -f /tmp/pip_aws_requirements.txt

# GCP
# hadolint ignore=SC1091,SC2129
RUN if [ "${GCP}" = "yes" ]; then \
    case "${TARGETARCH}" in \
      amd64) GCP_ARCHITECTURE=x86_64; GCP_SHA256="${GCP_SHA256_X86_64}" ;; \
      arm64) GCP_ARCHITECTURE=arm; GCP_SHA256="${GCP_SHA256_ARM}" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac ;\
    curl -fsSL "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCP_VERSION}-linux-${GCP_ARCHITECTURE}.tar.gz" -o google-cloud-sdk.tar.gz ;\
    echo "${GCP_SHA256}  google-cloud-sdk.tar.gz" | sha256sum -c - ;\
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
# using wget to bypass curl error for arm64 https://bugs.launchpad.net/ubuntu/+source/curl/+bug/2073448
# hadolint ignore=DL3009
RUN if [ "${AZURE}" = "yes" ]; then \
    mkdir -p /etc/apt/keyrings ;\
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/keyrings/microsoft.gpg > /dev/null ;\
    chmod go+r /etc/apt/keyrings/microsoft.gpg ;\
    AZ_DIST="$(lsb_release -cs)" ;\
    printf "Types: deb\n\
URIs: https://packages.microsoft.com/repos/azure-cli/\n\
Suites: %s\n\
Components: main\n\
Architectures: %s\n\
Signed-by: /etc/apt/keyrings/microsoft.gpg" "${AZ_DIST}" "$(dpkg --print-architecture)" | tee /etc/apt/sources.list.d/azure-cli.sources ;\
    apt-get update -y ;\
    apt-get install --no-install-recommends -y azure-cli="${AZ_VERSION}-1~${AZ_DIST}" ;\
    apt-get clean ;\
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* ;\
  fi

# Scripts and final cleanup
COPY fmt/format-hcl fmt/fmt.sh fmt/terragrunt-fmt.sh entrypoint.sh /usr/bin/
RUN chmod +x \
    /usr/bin/format-hcl \
    /usr/bin/fmt.sh \
    /usr/bin/terragrunt-fmt.sh \
    /usr/bin/entrypoint.sh ;\
  rm -rf /root/.cache/* /tmp/*

WORKDIR /data
CMD ["entrypoint.sh"]
