ARG BUILD_IMAGE=alpine
ARG BUILD_IMAGE_TAG=3.15.1
FROM ${BUILD_IMAGE}:${BUILD_IMAGE_TAG}

# Multi-architecture from buildx
ARG TARGETPLATFORM=linux/amd64

# Install prerequisits
SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]
RUN apk update --no-cache ;\
  apk add --no-cache \
    bash~=5.1.16 \
    bc~=1.07.1 \
    ca-certificates~=20211220 \
    curl~=7.80.0 \
    docker~=20.10.11 \
    git~=2.34.1 \
    jq~=1.6 \
    make~=4.3 \
    ncurses~=6.3 \
    openssh~=8.8 \
    openssl~=1.1.1 \
    python3~=3.9.7 \
    py3-pip~=20.3.4 \
    py3-wheel~=0.36.2 \
    unzip~=6.0 \
    zip~=3.0

# Install hub github cli
SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]
# hadolint ignore=DL3018
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing hub~=2.14.2

# Install build dependencies
SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]
RUN apk add --no-cache --virtual .build-deps \
      gcc~=10.3.1 \
      python3-dev~=3.9.7 \
      libffi-dev~=3.4.2 \
      musl-dev~=1.2.2 \
      openssl-dev~=1.1.1

# List of Python packages
COPY pip/common/requirements.txt /tmp/common_requirements.txt

# Python packages
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN pip3 install --no-cache-dir -r /tmp/common_requirements.txt

# Get Terraform by a specific version or search for the latest one
ARG TF_VERSION=latest
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then ARCHITECTURE=arm64; else ARCHITECTURE=amd64; fi ;\
  if [ "${TF_VERSION}" = "latest" ]; then \
  VERSION="$( curl -LsS https://releases.hashicorp.com/terraform/ \
    | grep -Eo '/[.0-9]+/' | grep -Eo '[.0-9]+' \
    | sort -V | tail -1 )" ;\
  else \
    VERSION="${TF_VERSION}" ;\
  fi ;\
  curl -LsS \
    https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_${ARCHITECTURE}.zip -o ./terraform.zip ;\
  unzip ./terraform.zip ;\
  rm -f ./terraform.zip ;\
  chmod +x ./terraform ;\
  mv ./terraform /usr/bin/terraform

# Get Terragrunt by a specific version or search for the latest one
ARG TG_VERSION=latest
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then ARCHITECTURE=arm64; else ARCHITECTURE=amd64; fi ;\
  if [ "${TG_VERSION}" = "latest" ]; then \
  VERSION="$( curl -LsS https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest \
    | jq -r .name )" ;\
  else \
    VERSION="v${TG_VERSION}" ;\
  fi ;\
  curl -LsS \
    https://github.com/gruntwork-io/terragrunt/releases/download/${VERSION}/terragrunt_linux_${ARCHITECTURE} -o /usr/bin/terragrunt ;\
  chmod +x /usr/bin/terragrunt

# Get latest TFLint
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then ARCHITECTURE=arm64; else ARCHITECTURE=amd64; fi ;\
  curl -LsS \
    "$( curl -LsS https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_${ARCHITECTURE}.zip" )" -o tflint.zip ;\
  unzip tflint.zip ;\
  rm -f tflint.zip ;\
  chmod +x tflint ;\
  mv tflint /usr/bin/tflint

# Get latest hcledit
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then ARCHITECTURE=arm64; else ARCHITECTURE=amd64; fi ;\
  curl -LsS \
    "$( curl -LsS https://api.github.com/repos/minamijoyo/hcledit/releases/latest | grep -o -E "https://.+?_linux_${ARCHITECTURE}.tar.gz" )" -o hcledit.tar.gz ;\
  tar -xf hcledit.tar.gz ;\
  rm -f hcledit.tar.gz ;\
  chmod +x hcledit ;\
  chown "$(id -u):$(id -g)" hcledit ;\
  mv hcledit /usr/bin/hcledit

# Get latest sops
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN curl -LsS \
    "$( curl -LsS https://api.github.com/repos/mozilla/sops/releases/latest | grep -o -E "https://.+?\.linux" | head -1 )" -o /usr/bin/sops ;\
  chmod +x /usr/bin/sops

# List of Python packages
COPY pip/aws/requirements.txt /tmp/aws_requirements.txt

# Cloud CLIs
ARG AWS=no
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN if [ "${AWS}" = "yes" ]; then \
    pip3 install --no-cache-dir -r /tmp/aws_requirements.txt ;\
  fi

# Disabled due to ld-linux-x86-64.so.2 errors in Alpine
#ARG GCP=no
#SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
## hadolint ignore=SC1091
#RUN if [ "${GCP}" = "yes" ]; then \
#    apk --no-cache add \
#      py3-crcmod~=1.7 \
#      py3-openssl~=21.0.0 \
#      libc6-compat~=1.2.2 \
#      gnupg~=2.2.31 ;\
#    curl https://sdk.cloud.google.com > /tmp/install.sh ;\
#    bash /tmp/install.sh --disable-prompts --install-dir=/ ;\
#    find /google-cloud-sdk/bin -maxdepth 1 -executable -type f -exec sh -c 'ln -s "$1" /usr/local/bin/$(basename "$1")' sh {} \; ;\
#    echo ". /google-cloud-sdk/completion.bash.inc" >> /root/.profile ;\
#    echo ". /google-cloud-sdk/path.bash.inc" >> /root/.profile ;\
#    gcloud config set core/disable_usage_reporting true ;\
#    gcloud config set component_manager/disable_update_check true ;\
#    gcloud config set metrics/environment github_docker_image ;\
#    git config --system credential.'https://source.developers.google.com'.helper gcloud.sh ;\
#    rm -f /tmp/install.sh ;\
#  fi

ARG AZURE=no
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN if [ "${AZURE}" = "yes" ]; then \
    pip install --no-cache-dir azure-cli==2.25.0 ;\
  fi

# Scripts, configs and cleanup
COPY fmt/format-hcl fmt/fmt.sh fmt/terragrunt-fmt.sh show-versions.sh /usr/bin/
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN chmod +x \
    /usr/bin/format-hcl \
    /usr/bin/fmt.sh \
    /usr/bin/terragrunt-fmt.sh \
    /usr/bin/show-versions.sh ;\
  # Cleanup
  apk del .build-deps ;\
  rm -rf /var/cache/* ;\
  rm -rf /root/.cache/* ;\
  rm -rf /tmp/*

# Labels for http://label-schema.org/rc1/#build-time-labels
# And for https://github.com/opencontainers/image-spec/blob/master/annotations.md
# And for https://help.github.com/en/actions/building-actions/metadata-syntax-for-github-actions
ARG NAME="IaaC dockerized framework for Terraform/Terragrunt"
ARG DESCRIPTION="Docker image with Terraform v${TF_VERSION}, Terragrunt v${TG_VERSION} and all needed components to easily manage cloud infrastructure."
ARG REPO_URL="https://github.com/devops-infra/docker-terragrunt"
ARG AUTHOR="Krzysztof Szyper <biotyk@mail.com>"
ARG HOMEPAGE="https://christophshyper.github.io/"
ARG BUILD_DATE=2020-04-01T00:00:00Z
ARG VCS_REF=abcdef1
ARG VERSION="tf-${TF_VERSION}-tg-${TG_VERSION}"
LABEL \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.name="${NAME}" \
  org.label-schema.description="${DESCRIPTION}" \
  org.label-schema.usage="README.md" \
  org.label-schema.url="${HOMEPAGE}" \
  org.label-schema.vcs-url="${REPO_URL}" \
  org.label-schema.vcs-ref="${VCS_REF}" \
  org.label-schema.vendor="${AUTHOR}" \
  org.label-schema.version="${VERSION}" \
  org.label-schema.schema-version="1.0"	\
  org.opencontainers.image.created="${BUILD_DATE}" \
  org.opencontainers.image.authors="${AUTHOR}" \
  org.opencontainers.image.url="${HOMEPAGE}" \
  org.opencontainers.image.documentation="${REPO_URL}/blob/master/README.md" \
  org.opencontainers.image.source="${REPO_URL}" \
  org.opencontainers.image.version="${VERSION}" \
  org.opencontainers.image.revision="${VCS_REF}" \
  org.opencontainers.image.vendor="${AUTHOR}" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.title="${NAME}" \
  org.opencontainers.image.description="${DESCRIPTION}" \
  maintainer="${AUTHOR}" \
  repository="${REPO_URL}"

WORKDIR /data
CMD ["show-versions.sh"]
