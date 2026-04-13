FROM ubuntu:noble-20260324

# Disable interactive mode
ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Multi-architecture from buildx
ARG TARGETARCH

# Which flavor of image to build
ARG SLIM=no
ARG TF=yes
ARG OT=no
ARG TG=yes
ARG AZURE=no
ARG AWS=no
ARG GCP=no
ARG YC=no

# Versions of dependencies
ARG AWS_VERSION=2.34.24
ARG GCP_VERSION=563.0.0
ARG AZ_VERSION=2.84.0
ARG TF_VERSION=1.14.8
ARG OT_VERSION=1.11.5
ARG TG_VERSION=1.0.0

# Pinned tool versions (override via --build-arg if needed)
ARG TFLINT_VERSION=0.59.1
ARG HCLEDIT_VERSION=0.2.17
ARG SOPS_VERSION=3.10.2

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Debug information
# hadolint ignore=DL3008,SC2015,SC2129
RUN echo Debug information: ;\
  echo TARGETARCH = "${TARGETARCH}" ;\
  if [ "${AWS}" = "yes" ]; then echo AWS_VERSION = "${AWS_VERSION}"; fi ;\
  if [ "${GCP}" = "yes" ]; then echo GCP_VERSION = "${GCP_VERSION}"; fi ;\
  if [ "${AZURE}" = "yes" ]; then echo AZ_VERSION = "${AZ_VERSION}"; fi ;\
  echo TF = "${TF}" ;\
  echo OT = "${OT}" ;\
  echo TG = "${TG}" ;\
  echo TF_VERSION = "${TF_VERSION}" ;\
  echo OT_VERSION = "${OT_VERSION}" ;\
  echo TG_VERSION = "${TG_VERSION}" ;\
  echo TFLINT_VERSION = "${TFLINT_VERSION}" ;\
  echo HCLEDIT_VERSION = "${HCLEDIT_VERSION}" ;\
  echo SOPS_VERSION = "${SOPS_VERSION}" ;\
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
      gh \
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
    curl -1sLf 'https://dl.cloudsmith.io/public/task/task/setup.deb.sh' | bash ;\
    apt-get update -y ;\
    apt-get install --no-install-recommends -y task ;\
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
  if [ "${TF}" = "yes" ]; then \
    TF_SHA256=$(curl -fsSL "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_SHA256SUMS" | awk '/terraform_[0-9.]+_linux_'"${ARCHITECTURE}"'\.zip$/ {print $1; exit}') ;\
    [ -n "${TF_SHA256}" ] || { echo "Missing Terraform checksum for ${TF_VERSION}/${ARCHITECTURE}"; exit 1; } ;\
    install_zip_binary "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${ARCHITECTURE}.zip" terraform "${TF_SHA256}" ;\
  else \
    echo "Skipping Terraform installation" ;\
  fi ;\
  if [ "${OT}" = "yes" ]; then \
    OT_DEB_SHA256=$(curl -fsSL "https://github.com/opentofu/opentofu/releases/download/v${OT_VERSION}/tofu_${OT_VERSION}_SHA256SUMS" | awk '/tofu_[0-9.]+_'"${ARCHITECTURE}"'\.deb$/ {print $1; exit}') ;\
    [ -n "${OT_DEB_SHA256}" ] || { echo "Missing OpenTofu checksum for ${OT_VERSION}/${ARCHITECTURE}"; exit 1; } ;\
    curl -fsSL "https://github.com/opentofu/opentofu/releases/download/v${OT_VERSION}/tofu_${OT_VERSION}_${ARCHITECTURE}.deb" -o "${TMP_DIR}/tofu.deb" ;\
    echo "${OT_DEB_SHA256}  ${TMP_DIR}/tofu.deb" | sha256sum -c - ;\
    dpkg -i "${TMP_DIR}/tofu.deb" ;\
  else \
    echo "Skipping OpenTofu installation" ;\
  fi ;\
  if [ "${TG}" = "yes" ]; then \
    TG_SHA256=$(curl -fsSL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TG_VERSION}/SHA256SUMS" | awk '/terragrunt_linux_'"${ARCHITECTURE}"'$/ {print $1; exit}') ;\
    [ -n "${TG_SHA256}" ] || { echo "Missing Terragrunt checksum for ${TG_VERSION}/${ARCHITECTURE}"; exit 1; } ;\
    curl -fsSL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TG_VERSION}/terragrunt_linux_${ARCHITECTURE}" -o /usr/bin/terragrunt ;\
    echo "${TG_SHA256}  /usr/bin/terragrunt" | sha256sum -c - ;\
    chmod +x /usr/bin/terragrunt ;\
  else \
    echo "Skipping Terragrunt installation" ;\
  fi ;\
  rm -rf "${TMP_DIR}"

# Install helper binaries in a dedicated layer for better cache locality
RUN case "${TARGETARCH}" in amd64|arm64) ARCHITECTURE="${TARGETARCH}" ;; *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; esac ;\
  if [ "${SLIM}" = "no" ]; then \
    TFLINT_SHA256=$(curl -fsSL "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/checksums.txt" | awk '/tflint_linux_'"${ARCHITECTURE}"'\.zip$/ {print $1; exit}') ;\
    [ -n "${TFLINT_SHA256}" ] || { echo "Missing TFLint checksum for ${TFLINT_VERSION}/${ARCHITECTURE}"; exit 1; } ;\
    HCLEDIT_SHA256=$(curl -fsSL "https://github.com/minamijoyo/hcledit/releases/download/v${HCLEDIT_VERSION}/hcledit_${HCLEDIT_VERSION}_checksums.txt" | awk '/hcledit_[0-9.]+_linux_'"${ARCHITECTURE}"'\.tar\.gz$/ {print $1; exit}') ;\
    [ -n "${HCLEDIT_SHA256}" ] || { echo "Missing hcledit checksum for ${HCLEDIT_VERSION}/${ARCHITECTURE}"; exit 1; } ;\
    SOPS_SHA256=$(curl -fsSL "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.checksums.txt" | awk '/sops-v[0-9.]+\.linux\.'"${ARCHITECTURE}"'$/ {print $1; exit}') ;\
    [ -n "${SOPS_SHA256}" ] || { echo "Missing sops checksum for ${SOPS_VERSION}/${ARCHITECTURE}"; exit 1; } ;\
    TMP_DIR="$(mktemp -d)" ;\
  fi ;\
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
  if [ "${SLIM}" = "no" ]; then \
    install_zip_binary "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${ARCHITECTURE}.zip" tflint "${TFLINT_SHA256}" ;\
    curl -fsSL "https://github.com/minamijoyo/hcledit/releases/download/v${HCLEDIT_VERSION}/hcledit_${HCLEDIT_VERSION}_linux_${ARCHITECTURE}.tar.gz" -o "${TMP_DIR}/hcledit.tar.gz" ;\
    echo "${HCLEDIT_SHA256}  ${TMP_DIR}/hcledit.tar.gz" | sha256sum -c - ;\
    tar -xf "${TMP_DIR}/hcledit.tar.gz" -C "${TMP_DIR}" ;\
    chmod +x "${TMP_DIR}/hcledit" ;\
    mv "${TMP_DIR}/hcledit" /usr/bin/hcledit ;\
    curl -fsSL "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${ARCHITECTURE}" -o /usr/bin/sops ;\
    echo "${SOPS_SHA256}  /usr/bin/sops" | sha256sum -c - ;\
    chmod +x /usr/bin/sops ;\
    rm -rf "${TMP_DIR}" ;\
  fi ;\
  true

# Cloud CLIs

# AWS
COPY pip/aws/requirements.txt /tmp/pip_aws_requirements.txt
COPY awscli_pgp_public_key.asc /tmp/awscli_pgp_public_key.asc
# hadolint ignore=DL3013
RUN if [ "${AWS}" = "yes" ]; then \
    case "${TARGETARCH}" in \
      amd64) AWS_ARCHITECTURE=x86_64 ;; \
      arm64) AWS_ARCHITECTURE=aarch64 ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac ;\
    xargs -n 1 -a /tmp/pip_aws_requirements.txt pip3 install --no-cache-dir ;\
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCHITECTURE}-${AWS_VERSION}.zip" -o /tmp/awscli.zip ;\
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCHITECTURE}-${AWS_VERSION}.zip.sig" -o /tmp/awscli.zip.sig ;\
    GNUPGHOME="$(mktemp -d)" ;\
    export GNUPGHOME ;\
    gpg --batch --import /tmp/awscli_pgp_public_key.asc ;\
    AWS_GPG_FINGERPRINT="" ;\
    AWS_GPG_FINGERPRINT="$(gpg --batch --with-colons --fingerprint "aws-cli@amazon.com" | awk -F: '/^fpr:/ {print $10; exit}')" ;\
    [ "${AWS_GPG_FINGERPRINT}" = "FB5DB77FD5C118B80511ADA8A6310ACC4672475C" ] ;\
    gpg --batch --verify /tmp/awscli.zip.sig /tmp/awscli.zip ;\
    rm -rf "${GNUPGHOME}" ;\
    mkdir -p /tmp/awscli ;\
    unzip -q /tmp/awscli.zip -d /tmp/awscli ;\
    /tmp/awscli/aws/install ;\
    rm -rf /tmp/awscli /tmp/awscli.zip /tmp/awscli.zip.sig /tmp/awscli_pgp_public_key.asc ;\
  fi ;\
  rm -f /tmp/pip_aws_requirements.txt /tmp/awscli_pgp_public_key.asc

# GCP
# hadolint ignore=SC1091,SC2129
RUN if [ "${GCP}" = "yes" ]; then \
    mkdir -p /usr/share/keyrings ;\
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor > /usr/share/keyrings/cloud.google.gpg ;\
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list ;\
    apt-get update -y ;\
    apt-get install --no-install-recommends -y google-cloud-cli="${GCP_VERSION}-0" ;\
    apt-get clean ;\
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* ;\
    gcloud config set component_manager/disable_update_check true ;\
    gcloud config set metrics/environment github_docker_image ;\
  fi

# Azure
# hadolint ignore=DL3009
RUN if [ "${AZURE}" = "yes" ]; then \
    mkdir -p /etc/apt/keyrings ;\
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/keyrings/microsoft.gpg > /dev/null ;\
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
