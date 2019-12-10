FROM debian:stable-slim as builder

# Install build dependencies on builder
RUN set -eux \
	&& DEBIAN_FRONTEND=noninteractive apt-get update -qq \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends --no-install-suggests \
		ca-certificates \
		curl \
		git \
		unzip \
	&& rm -rf /var/lib/apt/lists/*

# Get Terraform
# Contrary to orignal by cytopia (https://github.com/cytopia) TF_VERSION needs to point to explicit version, e.g. 0.12.17
# To choose latest from minor version provide a proper parameter for the Makefile
ARG TF_VERSION=latest
RUN set -eux \
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
	&& chmod +x /usr/bin/terraform

# Get Terragrunt
# Contrary to orignal by cytopia (https://github.com/cytopia) TG_VERSION needs to point to explicit version, e.g. 0.21.9
# To choose latest from minor version provide a proper parameter for the Makefile
ARG TG_VERSION=latest
RUN set -eux \
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
	&& chmod +x /usr/bin/terragrunt

# Get the latest Scenery
# This part was added
RUN set -eux \
	&& git clone https://github.com/dmlittle/scenery /scenery \
	&& cd /scenery \
	&& VERSION="$( git describe --abbrev=0 --tags )" \
	&& curl -sS -L \
		https://github.com/dmlittle/scenery/releases/download/${VERSION}/scenery-${VERSION}-linux-amd64 \
		-o /usr/bin/scenery \
	&& chmod +x /usr/bin/scenery

# Use a clean tiny image to store artifacts in
FROM alpine:3.9

# For http://label-schema.org/rc1/#build-time-labels
ARG VCS_REF
ARG BUILD_DATE
ARG TF_VERSION
ARG TG_VERSION
LABEL \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.description="Docker image with Terraform v${TF_VERSION}, Terragrunt v${TG_VERSION} and all needed components to easily manage AWS infrastructure." \
	org.label-schema.name="docker-terragrunt" \
	org.label-schema.schema-version="1.0"	\
    org.label-schema.url="https://github.com/Krzysztof-Szyper-Epam/docker-terragrunt" \
	org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.vcs-url="https://github.com/Krzysztof-Szyper-Epam/docker-terragrunt" \
    org.label-schema.vendor="Krzysztof Szyper <biotyk@mail.com>" \
    org.label-schema.version="${TF_VERSION}-${TG_VERSION}" \
    maintainer="Krzysztof Szyper <biotyk@mail.com>" \
    repository="https://github.com/Krzysztof-Szyper-Epam/docker-terragrunt" \
    tf_version="${TF_VERSION}" \
    tg_version="${TG_VERSION}"

# This part was moved and edited
# Combines scripts from docker-terragrunt-fmt with docker-terragrunt
COPY fmt/format-hcl.sh /usr/bin/format-hcl.sh
COPY fmt/fmt.sh /fmt.sh
COPY fmt/terragrunt-fmt.sh /terragrunt-fmt.sh
COPY --from=builder /usr/bin/terraform /usr/bin/terraform
COPY --from=builder /usr/bin/terragrunt /usr/bin/terragrunt
COPY --from=builder /usr/bin/scenery /usr/bin/scenery

# This part has some additions
RUN set -eux \
    && chmod +x /usr/bin/format-hcl.sh /fmt.sh /terragrunt-fmt.sh \
    && apk update --no-cache \
    && apk upgrade --no-cache \
	&& apk add --no-cache git \
	&& apk add --no-cache make \
	&& apk add --no-cache python3 \
	&& apk add --no-cache bash \
	&& apk add --no-cache curl \
	&& apk add --no-cache docker \
	&& apk add --no-cache zip \
	&& apk add --no-cache openssl \
	&& apk add --no-cache jq \
    && if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi \
    && python3 -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && pip3 install --no-cache --upgrade pip setuptools wheel \
    && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi \
    && python3 -m pip install ply \
	&& python3 -m pip install pyhcl \
	&& python3 -m pip install awscli \
    && python3 -m pip install boto3 \
    && rm -rf /var/cache/* \
    && rm -rf /root/.cache/*

WORKDIR /data
CMD terraform --version && terragrunt --version
