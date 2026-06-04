FROM alpine:3.23.4

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
ARG AWS_VERSION=2.32.7
ARG GCP_VERSION=571.0.0
ARG AZ_VERSION=2.87.0
ARG TF_VERSION=1.15.5
ARG OT_VERSION=1.12.1
ARG TG_VERSION=1.0.7

# Pinned tool versions (override via --build-arg if needed)
ARG TFLINT_VERSION=0.63.1
ARG HCLEDIT_VERSION=0.2.18
ARG SOPS_VERSION=3.13.1

COPY alpine-packages.txt /tmp/alpine-packages.txt
COPY alpine-packages-nonslim.txt /tmp/alpine-packages-nonslim.txt
COPY alpine-packages-aws.txt /tmp/alpine-packages-aws.txt
COPY pip/common/requirements.txt /tmp/pip_common_requirements.txt
COPY pip/aws/requirements.txt /tmp/pip_aws_requirements.txt

# Debug information and architecture resolution
SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]
RUN targetarch="${TARGETARCH:-}"; \
  if [ -z "${targetarch}" ]; then \
    case "$(uname -m)" in \
      x86_64) targetarch="amd64" ;; \
      aarch64|arm64) targetarch="arm64" ;; \
      *) echo "Unsupported host architecture: $(uname -m)"; exit 1 ;; \
    esac; \
  fi; \
  case "${targetarch}" in amd64|arm64) ;; *) echo "Unsupported architecture: ${targetarch}"; exit 1 ;; esac; \
  echo "TARGETARCH=${targetarch}"; \
  echo "AWS=${AWS} AWS_VERSION=${AWS_VERSION}"; \
  echo "GCP=${GCP} GCP_VERSION=${GCP_VERSION}"; \
  echo "AZURE=${AZURE} AZ_VERSION=${AZ_VERSION}"; \
  echo "TF=${TF} TF_VERSION=${TF_VERSION}"; \
  echo "OT=${OT} OT_VERSION=${OT_VERSION}"; \
  echo "TG=${TG} TG_VERSION=${TG_VERSION}"; \
  echo "TFLINT_VERSION=${TFLINT_VERSION}"; \
  echo "HCLEDIT_VERSION=${HCLEDIT_VERSION}"; \
  echo "SOPS_VERSION=${SOPS_VERSION}"; \
  printf '%s' "${targetarch}" > /tmp/targetarch

# Install pinned Alpine dependencies
SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]
# hadolint ignore=DL3018
RUN xargs -r apk add --no-cache < /tmp/alpine-packages.txt; \
  if [ "${SLIM}" = "no" ]; then \
    xargs -r apk add --no-cache < /tmp/alpine-packages-nonslim.txt; \
    pip3 install --no-cache-dir -r /tmp/pip_common_requirements.txt; \
    ln -sf /usr/bin/python3 /usr/bin/python; \
    ln -sf /usr/bin/pip3 /usr/bin/pip; \
  fi

# Install Terraform/OpenTofu/Terragrunt
SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]
# hadolint ignore=SC2155
RUN ARCHITECTURE="$(cat /tmp/targetarch)"; \
  TMP_DIR="$(mktemp -d)"; \
  install_zip_binary() { \
    url="$1"; \
    binary_name="$2"; \
    sha256="$3"; \
    zip_path="${TMP_DIR}/${binary_name}.zip"; \
    curl -fsSL "${url}" -o "${zip_path}"; \
    echo "${sha256}  ${zip_path}" | sha256sum -c -; \
    unzip -q "${zip_path}" -d "${TMP_DIR}"; \
    chmod +x "${TMP_DIR}/${binary_name}"; \
    mv "${TMP_DIR}/${binary_name}" "/usr/bin/${binary_name}"; \
  }; \
  if [ "${TF}" = "yes" ]; then \
    TF_SHA256="$(curl -fsSL "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_SHA256SUMS" | awk '/terraform_[0-9.]+_linux_'"${ARCHITECTURE}"'\.zip$/ {print $1; exit}')"; \
    [ -n "${TF_SHA256}" ] || { echo "Missing Terraform checksum for ${TF_VERSION}/${ARCHITECTURE}"; exit 1; }; \
    install_zip_binary "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${ARCHITECTURE}.zip" terraform "${TF_SHA256}"; \
  fi; \
  if [ "${OT}" = "yes" ]; then \
    OT_SHA256="$(curl -fsSL "https://github.com/opentofu/opentofu/releases/download/v${OT_VERSION}/tofu_${OT_VERSION}_SHA256SUMS" | awk '/tofu_[0-9.]+_linux_'"${ARCHITECTURE}"'\.tar\.gz$/ {print $1; exit}')"; \
    [ -n "${OT_SHA256}" ] || { echo "Missing OpenTofu checksum for ${OT_VERSION}/${ARCHITECTURE}"; exit 1; }; \
    curl -fsSL "https://github.com/opentofu/opentofu/releases/download/v${OT_VERSION}/tofu_${OT_VERSION}_linux_${ARCHITECTURE}.tar.gz" -o "${TMP_DIR}/tofu.tar.gz"; \
    echo "${OT_SHA256}  ${TMP_DIR}/tofu.tar.gz" | sha256sum -c -; \
    tar -xzf "${TMP_DIR}/tofu.tar.gz" -C "${TMP_DIR}" tofu; \
    chmod +x "${TMP_DIR}/tofu"; \
    mv "${TMP_DIR}/tofu" /usr/bin/tofu; \
  fi; \
  if [ "${TG}" = "yes" ]; then \
    TG_SHA256="$(curl -fsSL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TG_VERSION}/SHA256SUMS" | awk '/terragrunt_linux_'"${ARCHITECTURE}"'$/ {print $1; exit}')"; \
    [ -n "${TG_SHA256}" ] || { echo "Missing Terragrunt checksum for ${TG_VERSION}/${ARCHITECTURE}"; exit 1; }; \
    curl -fsSL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TG_VERSION}/terragrunt_linux_${ARCHITECTURE}" -o /usr/bin/terragrunt; \
    echo "${TG_SHA256}  /usr/bin/terragrunt" | sha256sum -c -; \
    chmod +x /usr/bin/terragrunt; \
  fi; \
  rm -rf "${TMP_DIR}"

# Install helper binaries for non-slim images
SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]
# hadolint ignore=SC2155
RUN if [ "${SLIM}" = "no" ]; then \
    ARCHITECTURE="$(cat /tmp/targetarch)"; \
    TMP_DIR="$(mktemp -d)"; \
    TFLINT_SHA256="$(curl -fsSL "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/checksums.txt" | awk '/tflint_linux_'"${ARCHITECTURE}"'\.zip$/ {print $1; exit}')"; \
    [ -n "${TFLINT_SHA256}" ] || { echo "Missing TFLint checksum for ${TFLINT_VERSION}/${ARCHITECTURE}"; exit 1; }; \
    HCLEDIT_SHA256="$(curl -fsSL "https://github.com/minamijoyo/hcledit/releases/download/v${HCLEDIT_VERSION}/hcledit_${HCLEDIT_VERSION}_checksums.txt" | awk '/hcledit_[0-9.]+_linux_'"${ARCHITECTURE}"'\.tar\.gz$/ {print $1; exit}')"; \
    [ -n "${HCLEDIT_SHA256}" ] || { echo "Missing hcledit checksum for ${HCLEDIT_VERSION}/${ARCHITECTURE}"; exit 1; }; \
    SOPS_SHA256="$(curl -fsSL "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.checksums.txt" | awk '/sops-v[0-9.]+\.linux\.'"${ARCHITECTURE}"'$/ {print $1; exit}')"; \
    [ -n "${SOPS_SHA256}" ] || { echo "Missing sops checksum for ${SOPS_VERSION}/${ARCHITECTURE}"; exit 1; }; \
    curl -fsSL "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${ARCHITECTURE}.zip" -o "${TMP_DIR}/tflint.zip"; \
    echo "${TFLINT_SHA256}  ${TMP_DIR}/tflint.zip" | sha256sum -c -; \
    unzip -q "${TMP_DIR}/tflint.zip" -d "${TMP_DIR}"; \
    chmod +x "${TMP_DIR}/tflint"; \
    mv "${TMP_DIR}/tflint" /usr/bin/tflint; \
    curl -fsSL "https://github.com/minamijoyo/hcledit/releases/download/v${HCLEDIT_VERSION}/hcledit_${HCLEDIT_VERSION}_linux_${ARCHITECTURE}.tar.gz" -o "${TMP_DIR}/hcledit.tar.gz"; \
    echo "${HCLEDIT_SHA256}  ${TMP_DIR}/hcledit.tar.gz" | sha256sum -c -; \
    tar -xzf "${TMP_DIR}/hcledit.tar.gz" -C "${TMP_DIR}"; \
    chmod +x "${TMP_DIR}/hcledit"; \
    mv "${TMP_DIR}/hcledit" /usr/bin/hcledit; \
    curl -fsSL "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${ARCHITECTURE}" -o /usr/bin/sops; \
    echo "${SOPS_SHA256}  /usr/bin/sops" | sha256sum -c -; \
    chmod +x /usr/bin/sops; \
    rm -rf "${TMP_DIR}"; \
  fi

# Cloud CLIs
SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]
RUN if [ "${AWS}" = "yes" ]; then \
    if [ "${SLIM}" = "yes" ]; then \
      echo "AWS flavor requires non-slim dependencies"; \
      exit 1; \
    fi; \
    xargs -n 1 -a /tmp/pip_aws_requirements.txt pip3 install --no-cache-dir; \
    xargs -r apk add --no-cache < /tmp/alpine-packages-aws.txt; \
    aws --version | grep -Eq '^aws-cli/[0-9]+\.[0-9]+'; \
  fi

SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]
RUN if [ "${GCP}" = "yes" ]; then \
    if [ "${SLIM}" = "yes" ]; then \
      echo "GCP flavor requires non-slim dependencies"; \
      exit 1; \
    fi; \
    ARCHITECTURE="$(cat /tmp/targetarch)"; \
    case "${ARCHITECTURE}" in \
      amd64) GCP_ARCH="x86_64" ;; \
      arm64) GCP_ARCH="arm" ;; \
      *) echo "Unsupported architecture for GCP CLI: ${ARCHITECTURE}"; exit 1 ;; \
    esac; \
    mkdir -p /opt; \
    curl -fsSL "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GCP_VERSION}-linux-${GCP_ARCH}.tar.gz" -o /tmp/google-cloud-cli.tar.gz; \
    tar -xzf /tmp/google-cloud-cli.tar.gz -C /opt; \
    /opt/google-cloud-sdk/install.sh --quiet --path-update=false --usage-reporting=false --command-completion=false --rc-path=/dev/null; \
    ln -sf /opt/google-cloud-sdk/bin/gcloud /usr/bin/gcloud; \
    gcloud config set component_manager/disable_update_check true; \
    gcloud config set metrics/environment github_docker_image; \
  fi

SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]
RUN if [ "${AZURE}" = "yes" ]; then \
    if [ "${SLIM}" = "yes" ]; then \
      echo "Azure flavor requires non-slim dependencies"; \
      exit 1; \
    fi; \
    pip3 install --no-cache-dir "azure-cli==${AZ_VERSION}"; \
    test "$(az version --output json | jq -r '."azure-cli"')" = "${AZ_VERSION}"; \
  fi

COPY fmt/format-hcl fmt/fmt.sh fmt/terragrunt-fmt.sh entrypoint.sh /usr/bin/
SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]
RUN chmod +x \
    /usr/bin/format-hcl \
    /usr/bin/fmt.sh \
    /usr/bin/terragrunt-fmt.sh \
    /usr/bin/entrypoint.sh; \
  terraform version >/dev/null 2>&1 || true; \
  tofu --version >/dev/null 2>&1 || true; \
  terragrunt --version >/dev/null 2>&1; \
  tflint --version >/dev/null 2>&1 || true; \
  hcledit version >/dev/null 2>&1 || true; \
  sops --version >/dev/null 2>&1 || true; \
  aws --version >/dev/null 2>&1 || true; \
  az --version >/dev/null 2>&1 || true; \
  gcloud --version >/dev/null 2>&1 || true; \
  rm -rf /var/cache/*; \
  rm -rf /root/.cache/*; \
  rm -rf /tmp/*

WORKDIR /data
CMD ["entrypoint.sh"]
