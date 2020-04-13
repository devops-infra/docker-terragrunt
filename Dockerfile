FROM debian:stable-slim as builder

# Set latest versions as default for Terraform and Terragrunt
ARG TF_VERSION=latest
ARG TG_VERSION=latest
ARG AWS=no
ARG GCP=no
ARG AZURE=no

# Install build dependencies on builder
RUN set -eux \
	&& DEBIAN_FRONTEND=noninteractive apt-get update -qq \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends --no-install-suggests \
		ca-certificates \
		curl \
		git \
		unzip \
	&& rm -rf /var/lib/apt/lists/* \
# Get Terraform by a specific version
	&& if [ "${TF_VERSION}" = "latest" ]; then \
		VERSION="$( curl -sS https://releases.hashicorp.com/terraform/ | cat \
			| grep -Eo '/[.0-9]+/' | grep -Eo '[.0-9]+' \
			| sort -V | tail -1 )"; \
	else \
		VERSION="${TF_VERSION}"; \
	fi \
	&& curl -sS -L -O \
		https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip \
	&& unzip terraform_${VERSION}_linux_amd64.zip \
	&& mv terraform /usr/bin/terraform \
	&& chmod +x /usr/bin/terraform \
# Get Terragrunt by a specific version
	&& git clone https://github.com/gruntwork-io/terragrunt /terragrunt \
	&& cd /terragrunt \
	&& if [ "${TG_VERSION}" = "latest" ]; then \
		VERSION="$( git describe --abbrev=0 --tags )"; \
	else \
		VERSION="v${TG_VERSION}";\
	fi \
	&& curl -sS -L \
		https://github.com/gruntwork-io/terragrunt/releases/download/${VERSION}/terragrunt_linux_amd64 \
		-o /usr/bin/terragrunt \
	&& chmod +x /usr/bin/terragrunt \
# Get the latest Scenery
	&& git clone https://github.com/dmlittle/scenery /scenery \
	&& cd /scenery \
	&& VERSION="$( git describe --abbrev=0 --tags )" \
	&& curl -sS -L \
		https://github.com/dmlittle/scenery/releases/download/${VERSION}/scenery-${VERSION}-linux-amd64 \
		-o /usr/bin/scenery \
	&& chmod +x /usr/bin/scenery \
# Get latest TFLint
	&& curl -L "$( curl -Ls https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip" )" \
    -o tflint.zip \
	&& unzip tflint.zip \
	&& mv tflint /usr/bin/tflint \
  && chmod +x /usr/bin/tflint

# Use a clean tiny image to store artifacts in
FROM alpine:3.11

# Labels for http://label-schema.org/rc1/#build-time-labels
# And for https://github.com/opencontainers/image-spec/blob/master/annotations.md
# And for https://help.github.com/en/actions/building-actions/metadata-syntax-for-github-actions
ARG NAME="IaaC dockerized framework for Terragrunt/Terragrunt"
ARG DESCRIPTION="Docker image with Terraform v${TF_VERSION}, Terragrunt v${TG_VERSION} and all needed components to easily manage cloud infrastructure."
ARG REPO_URL="https://github.com/ChristophShyper/docker-terragrunt"
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
  repository="${REPO_URL}" \
  aws_enabled="${AWS}"
  gcp_enabled="${GCP}" \
  azure_enabled="${AZURE}"

# Combines scripts from docker-terragrunt-fmt with docker-terragrunt
COPY fmt/format-hcl fmt/fmt.sh fmt/terragrunt-fmt.sh /usr/bin/
COPY --from=builder /usr/bin/terraform /usr/bin/terragrunt /usr/bin/scenery /usr/bin/tflint /usr/bin/

# This part has some additions
RUN set -eux \
  && chmod +x /usr/bin/format-hcl /usr/bin/fmt.sh /usr/bin/terragrunt-fmt.sh \
  && apk update --no-cache \
  && apk upgrade --no-cache \
	&& apk add --no-cache bash \
	&& apk add --no-cache curl \
	&& apk add --no-cache docker \
	&& apk add --no-cache git \
	&& apk add --no-cache jq \
	&& apk add --no-cache make \
	&& apk add --no-cache ncurses \
	&& apk add --no-cache openssh \
	&& apk add --no-cache openssl \
	&& apk add --no-cache python3 \
	&& apk add --no-cache zip \
  && if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi \
  && python3 -m ensurepip \
  && rm -r /usr/lib/python*/ensurepip \
  && pip3 install --no-cache --upgrade pip setuptools wheel \
  && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi \
  && python3 -m pip install ply --no-cache-dir \
	&& python3 -m pip install pyhcl --no-cache-dir \
  && if [ "${AWS}" == "yes" ]; then python3 -m pip install boto3 --no-cache-dir; python3 -m pip install awscli --no-cache-dir; fi \
#  && if [ "${GCP}" == "yes" ]; then echo GCP; fi \
#  && if [ "${AZURE}" == "yes" ]; then echo AZURE; fi \
  && mkdir -m 700 /root/.ssh \
  && touch -m 600 /root/.ssh/known_hosts \
  && ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts \
  && rm -rf /var/cache/* \
  && rm -rf /root/.cache/*

WORKDIR /data
CMD terraform --version && terragrunt --version
