FROM alpine:3.13

# Install prerequisits
SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]
# hadolint ignore=DL3018
RUN apk update --no-cache ;\
  apk add --no-cache \
    bash \
    bc \
    ca-certificates \
    curl \
    docker \
    git \
    jq \
    make \
    ncurses \
    openssh \
    openssl \
    python3 \
    py3-pip \
    unzip \
    zip ;\
  apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing hub

# Python packages
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=DL3013
RUN pip3 install --no-cache-dir \
    cloudflare \
    python-hcl2 \
    requests \
    slack_sdk

# Get Terraform by a specific version or search for the latest one
ARG TF_VERSION=latest
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN if [ "${TF_VERSION}" = "latest" ]; then \
    VERSION="$( curl -LsS https://releases.hashicorp.com/terraform/ \
      | grep -Eo '/[.0-9]+/' | grep -Eo '[.0-9]+' \
      | sort -V | tail -1 )" ;\
  else \
    VERSION="${TF_VERSION}" ;\
  fi ;\
  curl -LsS \
    https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip \
    -o ./terraform.zip ;\
  unzip ./terraform.zip ;\
  rm -f ./terraform.zip ;\
  chmod +x ./terraform ;\
  mv ./terraform /usr/bin/terraform

# Get Terragrunt by a specific version or search for the latest one
ARG TG_VERSION=latest
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN if [ "${TG_VERSION}" = "latest" ]; then \
    VERSION="$( curl -LsS https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest \
    | jq -r .name  | sed 's|v||' )" ;\
  else \
    VERSION="v${TG_VERSION}" ;\
  fi ;\
  curl -LsS \
    https://github.com/gruntwork-io/terragrunt/releases/download/${VERSION}/terragrunt_linux_amd64 \
    -o /usr/bin/terragrunt ;\
  chmod +x /usr/bin/terragrunt

# Get latest TFLint
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN curl -LsS "$( curl -LsS https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip" )" \
    -o tflint.zip ;\
  unzip tflint.zip ;\
  rm -f tflint.zip ;\
  chmod +x tflint ;\
  mv tflint /usr/bin/tflint

# Get latest hcledit
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=SC2046
RUN curl -LsS "$( curl -LsS https://api.github.com/repos/minamijoyo/hcledit/releases/latest | grep -o -E "https://.+?_linux_amd64.tar.gz" )" \
    -o hcledit.tar.gz ;\
  tar -xf hcledit.tar.gz ;\
  rm -f hcledit.tar.gz ;\
  chmod +x hcledit ;\
  chown $(id -u):$(id -g) hcledit ;\
  mv hcledit /usr/bin/hcledit

# Get latest sops
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN curl -LsS "$( curl -LsS https://api.github.com/repos/mozilla/sops/releases/latest | grep -o -E "https://.+?\.linux" )" \
    -o /usr/bin/sops ;\
  chmod +x /usr/bin/sops

# Cloud CLIs
ARG AWS=no
ARG GCP=no
ARG AZURE=no

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=DL3013
RUN if [ "${AWS}" = "yes" ]; then \
    pip3 install --no-cache-dir awscli boto3 ;\
  fi

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=DL3013
RUN  if [ "${GCP}" = "yes" ]; then echo GCP NOT READY; fi

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=DL3013,DL3018
RUN if [ "${AZURE}" = "yes" ]; then \
    apk add --no-cache --virtual .build-deps gcc python3-dev libffi-dev musl-dev openssl-dev ;\
    pip install --no-cache-dir azure-cli ;\
    apk del .build-deps; \
  fi

# Scripts, configs and cleanup
COPY fmt/format-hcl fmt/fmt.sh fmt/terragrunt-fmt.sh show-versions.sh /usr/bin/
COPY .gitconfig /root/
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN chmod +x \
    /usr/bin/format-hcl \
    /usr/bin/fmt.sh \
    /usr/bin/terragrunt-fmt.sh \
    /usr/bin/show-versions.sh ;\
  # Cleanup
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
