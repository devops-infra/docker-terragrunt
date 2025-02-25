.PHONY: phony
phony: help

# Provide versions of the main dependencies to use with this Docker image
AWS_VERSION := 2.24.11
GCP_VERSION := 511.0.0
AZ_VERSION = 2.69.0
TF_VERSION := 1.10.5
OT_VERSION := 1.9.0
TG_VERSION := 0.73.13

# GitHub Actions bogus variables
GITHUB_REF ?= refs/heads/null
GITHUB_SHA ?= aabbccddeeff
VERSION_PREFIX ?=

# Set version tags
TF_LATEST := $(shell curl -LsS https://api.github.com/repos/hashicorp/terraform/releases/latest | jq -r .tag_name | sed 's/^v//')
OT_LATEST := $(shell curl -LsS https://api.github.com/repos/opentofu/opentofu/releases/latest | jq -r .tag_name | sed 's/^v//')
TG_LATEST := $(shell curl -LsS https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r .tag_name | sed 's/^v//')
TF_TG_VERSION := tf-$(TF_VERSION)-tg-$(TG_VERSION)
OT_TG_VERSION := ot-$(OT_VERSION)-tg-$(TG_VERSION)
TF_TG_LATEST := tf-$(TF_LATEST)-tg-$(TG_LATEST)
OT_TG_LATEST := ot-$(OT_LATEST)-tg-$(TG_LATEST)
FULL_VERSION := tf-$(TF_VERSION)-ot-$(OT_VERSION)-tg-$(TG_VERSION)
AWS_LATEST := $(shell curl -LsS https://api.github.com/repos/aws/aws-cli/tags | jq -r .[].name | head -1)
GCP_LATEST := $(shell curl -LsS https://cloud.google.com/sdk/docs/downloads-versioned-archives | grep -o 'google-cloud-sdk-[0-9.]\+' | head -1 | sed 's/google-cloud-sdk-*//')
AZ_LATEST := $(shell curl -s https://pypi.org/pypi/azure-cli/json | jq -r '.info.version' | sed s'/azure-cli-//')

# Other variables and constants
CURRENT_BRANCH := $(shell echo $(GITHUB_REF) | sed 's/refs\/heads\///')
GITHUB_SHORT_SHA := $(shell echo $(GITHUB_SHA) | cut -c1-7)
DOCKER_USERNAME := christophshyper
DOCKER_ORG_NAME := devopsinfra
DOCKER_IMAGE := docker-terragrunt
DOCKER_NAME := $(DOCKER_ORG_NAME)/$(DOCKER_IMAGE)
DOCKER_HUB_API := https://hub.docker.com/v2
GITHUB_USERNAME := ChristophShyper
GITHUB_ORG_NAME := devops-infra
GITHUB_NAME := ghcr.io/$(GITHUB_ORG_NAME)/$(DOCKER_IMAGE)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
FLAVOURS := aws azure aws-azure gcp aws-gcp azure-gcp aws-azure-gcp yc

# Labels and annotations for Docker images
# Labels for http://label-schema.org/rc1/#build-time-labels
# And for https://github.com/opencontainers/image-spec/blob/master/annotations.md
# And for https://help.github.com/en/actions/building-actions/metadata-syntax-for-github-actions
LABEL_AUTHOR := Krzysztof ChristophShyper Szyper <biotyk@mail.com>
LABEL_NAME := IaaC dockerized framework for Terragrunt, Terraform and OpenTofu
LABEL_DESCRIPTION := Docker image with Terragrunt v$(TG_VERSION), Terraform v$(TF_VERSION) or OpenTofu v$(OT_VERSION), together with all needed components to easily manage cloud infrastructure.
LABEL_REPO_URL := https://github.com/devops-infra/docker-terragrunt
LABEL_HOMEPAGE := https://shyper.pro
LABEL_VENDOR := DevOps-Infra

# Common part of docker build command
DOCKER_COMMAND := docker buildx build \
	--platform linux/amd64,linux/arm64 \
	--file=Dockerfile \
	--annotation "index:org.label-schema.build-date=$(BUILD_DATE)" \
	--annotation "index:org.label-schema.name=$(LABEL_NAME)" \
	--annotation "index:org.label-schema.description=$(LABEL_DESCRIPTION)" \
	--annotation "index:org.label-schema.usage=$(LABEL_REPO_URL)/blob/$(GITHUB_SHA)/README.md" \
	--annotation "index:org.label-schema.url=$(LABEL_HOMEPAGE)" \
	--annotation "index:org.label-schema.vcs-url=$(LABEL_REPO_URL)" \
	--annotation "index:org.label-schema.vcs-ref=$(GITHUB_SHORT_SHA)" \
	--annotation "index:org.label-schema.vendor=$(LABEL_VENDOR)" \
	--annotation "index:org.label-schema.version=$(FULL_VERSION)" \
	--annotation "index:org.label-schema.schema-version=1.0"	\
	--annotation "index:org.opencontainers.image.created=$(BUILD_DATE)" \
	--annotation "index:org.opencontainers.image.authors=$(LABEL_AUTHOR)" \
	--annotation "index:org.opencontainers.image.url=$(LABEL_HOMEPAGE)" \
	--annotation "index:org.opencontainers.image.documentation=$(LABEL_REPO_URL)/blob/$(GITHUB_SHA)/README.md" \
	--annotation "index:org.opencontainers.image.source=$(LABEL_REPO_URL)" \
	--annotation "index:org.opencontainers.image.version=$(FULL_VERSION)" \
	--annotation "index:org.opencontainers.image.revision=$(GITHUB_SHORT_SHA)" \
	--annotation "index:org.opencontainers.image.vendor=$(LABEL_VENDOR)" \
	--annotation "index:org.opencontainers.image.licenses=MIT" \
	--annotation "index:org.opencontainers.image.title=$(LABEL_NAME)" \
	--annotation "index:org.opencontainers.image.description=$(LABEL_DESCRIPTION)" \
	--label org.label-schema.build-date="$(BUILD_DATE)" \
	--label org.label-schema.name="$(LABEL_NAME)" \
	--label org.label-schema.description="$(LABEL_DESCRIPTION)" \
	--label org.label-schema.usage="$(LABEL_REPO_URL)/blob/$(GITHUB_SHA)/README.md" \
	--label org.label-schema.url="$(LABEL_HOMEPAGE)" \
	--label org.label-schema.vcs-url="$(LABEL_REPO_URL)" \
	--label org.label-schema.vcs-ref="$(GITHUB_SHORT_SHA)" \
	--label org.label-schema.vendor="$(LABEL_VENDOR)" \
	--label org.label-schema.version="$(FULL_VERSION)" \
	--label org.label-schema.schema-version="1.0"	\
	--label org.opencontainers.image.created="$(BUILD_DATE)" \
	--label org.opencontainers.image.authors="$(LABEL_AUTHOR)" \
	--label org.opencontainers.image.url="$(LABEL_HOMEPAGE)" \
	--label org.opencontainers.image.documentation="$(LABEL_REPO_URL)/blob/$(GITHUB_SHA)/README.md" \
	--label org.opencontainers.image.source="$(LABEL_REPO_URL)" \
	--label org.opencontainers.image.version="$(FULL_VERSION)" \
	--label org.opencontainers.image.revision="$(GITHUB_SHORT_SHA)" \
	--label org.opencontainers.image.vendor="$(LABEL_VENDOR)" \
	--label org.opencontainers.image.licenses="MIT" \
	--label org.opencontainers.image.title="$(LABEL_NAME)" \
	--label org.opencontainers.image.description="$(LABEL_DESCRIPTION)" \
	--label maintainer="$(LABEL_AUTHOR)" \
	--label repository="$(LABEL_REPO_URL)"

# Some cosmetics
SHELL := bash
TXT_RED := $(shell tput setaf 1)
TXT_GREEN := $(shell tput setaf 2)
TXT_YELLOW := $(shell tput setaf 3)
TXT_RESET := $(shell tput sgr0)
define NL


endef

# Main actions

.PHONY: help
help: ## Display help prompt
	$(info Available options:)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(TXT_YELLOW)%-25s $(TXT_RESET) %s\n", $$1, $$2}'


.PHONY: update-versions
update-versions: ## Check TF, OT, and TG versions and update if there's newer version available
	$(info $(NL)$(TXT_GREEN) == CURRENT VERSIONS ==$(TXT_RESET))
	@echo -e "$(TXT_GREEN)Current Terraform:$(TXT_YELLOW)  $(TF_VERSION)$(TXT_RESET)"
	@if [[ $(TF_VERSION) != $(TF_LATEST) ]]; then \
  		echo -e "$(TXT_RED)Latest Terraform:$(TXT_YELLOW)   $(TF_LATEST)$(TXT_RESET)" ;\
  		sed -i 's/$(TF_VERSION)/$(TF_LATEST)/g' Makefile ;\
		sed -i 's/$(TF_VERSION)/$(TF_LATEST)/g' README.md ;\
  	fi
	@echo -e "$(TXT_GREEN)Current Terragrunt:$(TXT_YELLOW) $(TG_VERSION)$(TXT_RESET)"
	@if [[ $(TG_VERSION) != $(TG_LATEST) ]]; then \
  		echo -e "$(TXT_RED)Latest Terragrunt:$(TXT_YELLOW)  $(TG_LATEST)$(TXT_RESET)" ;\
  		sed -i 's/$(TG_VERSION)/$(TG_LATEST)/g' Makefile ;\
		sed -i 's/$(TG_VERSION)/$(TG_LATEST)/g' README.md ;\
  	fi
	@echo -e "$(TXT_GREEN)Current OpenTofu:$(TXT_YELLOW) $(OT_VERSION)$(TXT_RESET)"
	@if [[ $(OT_VERSION) != $(OT_LATEST) ]]; then \
  		echo -e "$(TXT_RED)Latest OpenTofu:$(TXT_YELLOW) $(OT_LATEST)$(TXT_RESET)" ;\
  		sed -i 's/$(OT_VERSION)/$(OT_LATEST)/g' Makefile ;\
		sed -i 's/$(OT_VERSION)/$(OT_LATEST)/g' README.md ;\
  	fi
	@echo -e "$(TXT_GREEN)Current AWS CLI:$(TXT_YELLOW)    $(AWS_VERSION)$(TXT_RESET)"
	@if [[ $(AWS_VERSION) != $(AWS_LATEST) ]]; then \
  		echo -e "$(TXT_RED)Latest AWS CLI:$(TXT_YELLOW)     $(AWS_LATEST)$(TXT_RESET)" ;\
  		sed -i 's/$(AWS_VERSION)/$(AWS_LATEST)/g' Makefile ;\
  	fi
	@echo -e "$(TXT_GREEN)Current GCP CLI:$(TXT_YELLOW)    $(GCP_VERSION)$(TXT_RESET)"
	@if [[ $(GCP_VERSION) != $(GCP_LATEST) ]]; then \
  		echo -e "$(TXT_RED)Latest GCP CLI:$(TXT_YELLOW)     $(GCP_LATEST)$(TXT_RESET)" ;\
  		sed -i 's/$(GCP_VERSION)/$(GCP_LATEST)/g' Makefile ;\
  	fi
	@echo -e "$(TXT_GREEN)Current Azure CLI:$(TXT_YELLOW)    $(AZ_VERSION)$(TXT_RESET)"
	@if [[ $(AZ_VERSION) != $(AZ_LATEST) ]]; then \
  		echo -e "$(TXT_RED)Latest Azure CLI:$(TXT_YELLOW)     $(AZ_LATEST)$(TXT_RESET)" ;\
  		sed -i 's/$(AZ_VERSION)/$(AZ_LATEST)/g' Makefile ;\
  	fi
	@if [[ $(TF_VERSION) != $(TF_LATEST) ]] || [[ $(TG_VERSION) != $(TG_LATEST) ]] || [[ $(AWS_VERSION) != $(AWS_LATEST) ]] || [[ $(GCP_VERSION) != $(GCP_LATEST) ]] || [[ $(AZ_VERSION) != $(AZ_LATEST) ]]; then \
  		echo -e "\n$(TXT_YELLOW) == UPDATING VERSIONS ==$(TXT_RESET)" ;\
  		echo "VERSION_TAG=tf-$(TF_LATEST)-ot-$(OT_LATEST)-tg-$(TG_LATEST)-aws-$(AWS_LATEST)-gcp-$(GCP_LATEST)-az-$(AZ_VERSION)" >> $(GITHUB_ENV) ;\
  	else \
  	  	echo "VERSION_TAG=null" >> $(GITHUB_ENV) ;\
  	fi


.PHONY: login
login: ## Log into all registries
	@echo -e "\n$(TXT_GREEN)Logging to: $(TXT_YELLOW)Docker Hub$(TXT_RESET)"
	@echo $(DOCKER_TOKEN) | docker login -u $(DOCKER_USERNAME) --password-stdin
	@echo -e "\n$(TXT_GREEN)Logging to: $(TXT_YELLOW)GitHub Packages$(TXT_RESET)"
	@echo $(GITHUB_TOKEN) | docker login ghcr.io -u $(GITHUB_USERNAME) --password-stdin



.PHONY: delete-stale-images
delete-stale-images: ## Delete stale images from DockerHub that haven't been pulled in 6 months
	$(info $(NL)$(TXT_GREEN)Deleting stale Docker images...$(TXT_RESET))
	@PAGE=1; \
		while true; do \
			echo "Fetching page $$PAGE..."; \
			RESPONSE=$$(curl -s -u "$(DOCKER_USERNAME):$(DOCKER_TOKEN)" \
				"$(DOCKER_HUB_API)/repositories/$(DOCKER_ORG_NAME)/$(DOCKER_IMAGE)/tags/?page_size=1000&page=$$PAGE"); \
			TAGS=$$(echo "$$RESPONSE" | jq -r '.results[] | select(.tag_last_pulled == null or (.tag_last_pulled | sub("\\.[0-9]+Z$$"; "Z") | fromdateiso8601 < (now - 15552000))) | .name'); \
			if [ -z "$$TAGS" ]; then \
				echo "No more stale images found on page $$PAGE."; \
			else \
				echo -e "Deleting stale images on page $$PAGE: \n$$TAGS"; \
				for TAG in $$TAGS; do \
					echo "Deleting tag: $$TAG"; \
					echo curl -s -u "$(DOCKER_USERNAME):$(DOCKER_TOKEN)" \
						-X DELETE \
						"$(DOCKER_HUB_API)/repositories/$(DOCKER_ORG_NAME)/$(DOCKER_IMAGE)/tags/$$TAG/"; \
				done; \
			fi; \
			NEXT_PAGE=$$(echo "$$RESPONSE" | jq -r '.next'); \
			if [ "$$NEXT_PAGE" = "null" ]; then \
				echo "No more pages to process."; \
				break; \
			fi; \
			PAGE=$$((PAGE + 1)); \
			sleep 3; \
		done


.PHONY: build-all
build-all: build-slim build-plain build-aws build-azure build-aws-azure build-gcp build-aws-gcp build-azure-gcp build-aws-azure-gcp ## Build all Docker images one by one


.PHONY: build-parallel
build-parallel: ## Build all image in parallel
	# build plain image first so unconditional layers can be reused
	@make -s build-slim VERSION_PREFIX=$(VERSION_PREFIX)
	@make -s build-plain VERSION_PREFIX=$(VERSION_PREFIX)
	@for FL in $(FLAVOURS); do \
			make -s build-$$FL VERSION_PREFIX=$(VERSION_PREFIX) &\
		done ;\
		wait


.PHONY: build-slim
build-slim: ## Build slim image without cloud CLIs and any additional software
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)slim-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)slim-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg SLIM=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)slim-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)slim-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)slim-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)slim-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)slim-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)slim-latest .
	@$(DOCKER_COMMAND) \
		--build-arg SLIM=yes \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)slim-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)slim-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)slim-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)slim-ot-latest .


.PHONY: build-plain
build-plain: ## Build image without cloud CLIs
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)plain-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)plain-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)plain-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)plain-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)plain-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)plain-latest .
	@$(DOCKER_COMMAND) \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)ot-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)plain-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)plain-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)plain-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)plain-ot-latest .


.PHONY: build-aws
build-aws: ## Build image with AWS CLI
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-latest .
	@$(DOCKER_COMMAND) \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-ot-latest .


.PHONY: build-azure
build-azure: ## Build image with Azure CLI
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg AZURE=yes \
		--build-arg AZ_VERSION=$(AZ_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-latest .
	@$(DOCKER_COMMAND) \
		--build-arg AZURE=yes \
		--build-arg AZ_VERSION=$(AZ_VERSION) \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-ot-latest .


.PHONY: build-aws-azure
build-aws-azure: ## Build image with AWS and Azure CLI
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg AZURE=yes \
		--build-arg AZ_VERSION=$(AZ_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-tf-latest .
	@$(DOCKER_COMMAND) \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg AZURE=yes \
		--build-arg AZ_VERSION=$(AZ_VERSION) \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-ot-latest .


.PHONY: build-gcp
build-gcp: ## Build image with GCP CLI
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)gcp-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)gcp-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)gcp-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)gcp-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)gcp-latest .
	@$(DOCKER_COMMAND) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)gcp-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)gcp-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)gcp-ot-latest .


.PHONY: build-aws-gcp
build-aws-gcp: ## Build image with AWS and GCP CLI
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-gcp-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-gcp-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-gcp-latest .
	@$(DOCKER_COMMAND) \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-gcp-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-gcp-ot-latest .


.PHONY: build-azure-gcp
build-azure-gcp: ## Build image with Azure and GCP CLI
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(TF_TG_VERSION)$(TXT_RESET) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg AZURE=yes \
		--build-arg AZ_VERSION=$(AZ_VERSION) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-gcp-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-gcp-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-gcp-latest .
	@$(DOCKER_COMMAND) \
		--build-arg AZURE=yes \
		--build-arg AZ_VERSION=$(AZ_VERSION) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-gcp-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-gcp-ot-latest .


.PHONY: build-aws-azure-gcp
build-aws-azure-gcp: ## Build image with AWS, Azure and GCP CLI
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg AZURE=yes \
		--build-arg AZ_VERSION=$(AZ_VERSION) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-gcp-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-gcp-latest .
	@$(DOCKER_COMMAND) \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg AZURE=yes \
		--build-arg AZ_VERSION=$(AZ_VERSION) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-gcp-ot-latest .


.PHONY: build-yc
build-yc: ## Build image with YandexCloud CLI
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)yc-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)yc-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg YC=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)yc-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)yc-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)yc-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)yc-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)yc-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)yc-latest .
	@$(DOCKER_COMMAND) \
		--build-arg YC=yes \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)yc-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)yc-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)yc-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)yc-ot-latest .


.PHONY: push-parallel
push-parallel: ## Push all images in parallel
	$(info $(NL)$(TXT_GREEN) == STARTING DEPLOYMENT == $(TXT_RESET)$(NL))
	@make -s push-slim VERSION_PREFIX=$(VERSION_PREFIX)
	@make -s push-plain VERSION_PREFIX=$(VERSION_PREFIX)
	@for FL in $(FLAVOURS); do \
			make -s push-$$FL VERSION_PREFIX=$(VERSION_PREFIX) &\
		done ;\
		wait


.PHONY: push-slim
push-slim: login ## Push only slim image
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)slim-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)slim-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg SLIM=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)slim-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)slim-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)slim-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)slim-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)slim-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)slim-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_IMAGE):$(VERSION_PREFIX)slim-$(TF_TG_VERSION)$(TXT_RESET)"
	@$(DOCKER_COMMAND) --push \
		--build-arg SLIM=yes \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)slim-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)slim-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)slim-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)slim-ot-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_IMAGE):$(VERSION_PREFIX)slim-$(OT_TG_VERSION)$(TXT_RESET)"


.PHONY: push-plain
push-plain: login ## Push only plain image
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)plain-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)plain-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)plain-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)plain-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)plain-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)plain-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_IMAGE):$(VERSION_PREFIX)$(TF_TG_VERSION)$(TXT_RESET)"
	@$(DOCKER_COMMAND) --push \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)ot-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)plain-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)plain-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)plain-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)plain-ot-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_IMAGE):$(VERSION_PREFIX)$(OT_TG_VERSION)$(TXT_RESET)"


.PHONY: push-aws
push-aws: login ## Push image with AWS CLI
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-$(TF_TG_VERSION)$(TXT_RESET)"
	@$(DOCKER_COMMAND) --push \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-ot-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-$(OT_TG_VERSION)$(TXT_RESET)"


.PHONY: push-azure
push-azure: login ## Push image with Azure CLI
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg AZURE=yes \
		--build-arg AZ_VERSION=$(AZ_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-$(TF_TG_VERSION)$(TXT_RESET)"
	@$(DOCKER_COMMAND) --push \
		--build-arg AZURE=yes \
		--build-arg AZ_VERSION=$(AZ_VERSION) \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-ot-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-$(OT_TG_VERSION)$(TXT_RESET)"


.PHONY: push-aws-azure
push-aws-azure: login ## Push image with AWS and Azure CLI
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg AZURE=yes \
		--build-arg AZ_VERSION=$(AZ_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(TF_TG_VERSION)$(TXT_RESET)"
	@$(DOCKER_COMMAND) --push \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg AZURE=yes \
		--build-arg AZ_VERSION=$(AZ_VERSION) \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-ot-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(OT_TG_VERSION)$(TXT_RESET)"


.PHONY: push-gcp
push-gcp: login ## Push image with GCP CLI
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)gcp-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)gcp-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)gcp-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)gcp-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)gcp-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(TF_TG_VERSION)$(TXT_RESET)"
	@$(DOCKER_COMMAND) --push \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)gcp-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)gcp-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)gcp-ot-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(OT_TG_VERSION)$(TXT_RESET)"


.PHONY: push-aws-gcp
push-aws-gcp: login ## Push image with AWS and GCP CLI
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-gcp-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-gcp-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-gcp-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(TF_TG_VERSION)$(TXT_RESET)"
	@$(DOCKER_COMMAND) --push \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-gcp-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-gcp-ot-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(OT_TG_VERSION)$(TXT_RESET)"


.PHONY: push-azure-gcp
push-azure-gcp: login ## Push image with Azure and GCP CLI
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg AZURE=yes \
		--build-arg AZ_VERSION=$(AZ_VERSION) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-gcp-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-gcp-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-gcp-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(TF_TG_VERSION)$(TXT_RESET)"
	@$(DOCKER_COMMAND) --push \
		--build-arg AZURE=yes \
		--build-arg AZ_VERSION=$(AZ_VERSION) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-gcp-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-gcp-ot-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(OT_TG_VERSION)$(TXT_RESET)"


.PHONY: push-aws-azure-gcp
push-aws-azure-gcp: login ## Push image with AWS, Azure and GCP CLI
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg AZURE=yes \
		--build-arg AZ_VERSION=$(AZ_VERSION) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-gcp-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-gcp-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(TF_TG_VERSION)$(TXT_RESET)"
	@$(DOCKER_COMMAND) --push \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg AZURE=yes \
		--build-arg AZ_VERSION=$(AZ_VERSION) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-gcp-ot-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(OT_TG_VERSION)$(TXT_RESET)"


.PHONY: push-yc
push-yc: login ## Push image with YandexCloud CLI
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)yc-$(TF_TG_VERSION) $(TXT_GREEN)and $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)yc-$(OT_TG_VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg YC=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg OT_VERSION=none \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)yc-$(TF_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)yc-tf-latest \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)yc-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)yc-$(TF_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)yc-tf-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)yc-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)yc-$(TF_TG_VERSION)$(TXT_RESET)"
	@$(DOCKER_COMMAND) --push \
		--build-arg YC=yes \
		--build-arg TF_VERSION=none \
		--build-arg OT_VERSION=$(OT_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)yc-$(OT_TG_VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)yc-ot-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)yc-$(OT_TG_VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)yc-ot-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)yc-$(OT_TG_VERSION)$(TXT_RESET)"
