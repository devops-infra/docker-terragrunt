FROM debian:stable-slim as builder

# Install build dependencies
RUN set -eux \
	&& DEBIAN_FRONTEND=noninteractive apt-get update -qq \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends --no-install-suggests \
		ca-certificates \
		curl \
		git \
		unzip

# Get Terraform
# Contrary to orignal by cytopia (https://github.com/cytopia) TF_VERSION needs to point to explicit version, e.g. 0.12.16
ARG TF_VERSION=latest
RUN set -eux \
	&& if [ "${TF_VERSION}" = "latest" ]; then \
		VERSION="$( curl -sS https://releases.hashicorp.com/terraform/ \
			| tac | tac \
			| grep -Eo '/[.0-9]+/' \
			| grep -Eo '[.0-9]+' \
			| sort -V \
			| tail -1 )"; \
	else \
		VERSION="$( curl -sS https://releases.hashicorp.com/terraform/ \
			| tac | tac \
			| grep -Eo "/${TF_VERSION}/" \
			| grep -Eo '[.0-9]+' \
			| sort -V \
			| tail -1 )"; \
	fi \
	&& curl -sS -L -O \
		https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip \
	&& unzip terraform_${VERSION}_linux_amd64.zip \
	&& mv terraform /usr/bin/terraform \
	&& chmod +x /usr/bin/terraform

# Get Terragrunt
# Contrary to orignal by cytopia (https://github.com/cytopia) TG_VERSION needs to point to explicit version, e.g. 0.21.6
ARG TG_VERSION=latest
RUN set -eux \
	&& git clone https://github.com/gruntwork-io/terragrunt /terragrunt \
	&& cd /terragrunt \
	&& if [ "${TG_VERSION}" = "latest" ]; then \
		VERSION="$( git describe --abbrev=0 --tags )"; \
	else \
		VERSION="$( git tag | grep -E "v${TG_VERSION}" | sort -u | tail -1 )" ;\
	fi \
	&& curl -sS -L \
		https://github.com/gruntwork-io/terragrunt/releases/download/${VERSION}/terragrunt_linux_amd64 \
		-o /usr/bin/terragrunt \
	&& chmod +x /usr/bin/terragrunt

# Get latest Scenery
# This part was added
RUN set -eux \
	&& git clone https://github.com/dmlittle/scenery /scenery \
	&& cd /scenery \
	&& VERSION="$( git describe --abbrev=0 --tags )"
	&& curl -sS -L \
		https://github.com/dmlittle/scenery/releases/download/${VERSION}/scenery-${VERSION}-linux-amd64 \
		-o /usr/bin/scenery \
	&& chmod +x /usr/bin/scenery

# Use a clean tiny image to store artifacts in
FROM alpine:3.9
# This part was eddited
LABEL \
	maintainer="Krzysztof Szyper <krzysztof_szyper@epam.com>" \
	repo="https://github.com/Krzysztof-Szyper-Epam/docker-terragrunt" \
	original_maintainer="cytopia <cytopia@everythingcli.org>" \
	original_repo="https://github.com/cytopia/docker-terragrunt"
# This part has some additions
RUN set -eux \
	&& apk add --no-cache git \
	&& apk add --no-cache make \
	&& apk add --no-cache python3 \
	&& apk add --no-cache bash \
	&& apk add --no-cache curl \
	&& apk add --no-cache docker \
	&& apk add --no-cache zip \
	&& apk add --no-cache openssl \
    && if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi \
    && python3 -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && pip3 install --no-cache --upgrade pip setuptools wheel \
    && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi \
    && python -m pip install ply \
	&& python -m pip install pyhcl \
	&& python -m pip install awscli
# This part was added and edited
COPY fmt/format-hcl.sh /usr/bin/format-hcl.sh
COPY fmt/fmt.sh /fmt.sh
COPY fmt/terragrunt-fmt.sh /terragrunt-fmt.sh
COPY --from=builder /usr/bin/terraform /usr/bin/terraform
COPY --from=builder /usr/bin/terragrunt /usr/bin/terragrunt
COPY --from=builder /usr/bin/scenery /usr/bin/scenery

WORKDIR /data
CMD terraform --version && terragrunt --version
