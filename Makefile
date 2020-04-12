.PHONY: phony
phony: help

# Provide versions of Terraform and Terragrunt to use with this Docker image
# Can be full (e.g. 0.12.24) or partial (e.g. 0.12 - which will get latest in that family)
TF_VERSION ?= latest
TG_VERSION ?= latest

# GitHub Actions bogus variables
GITHUB_REF ?= refs/heads/null
GITHUB_SHA ?= aabbccddeeff

# Other variables and constants
CURRENT_BRANCH := $(shell echo $(GITHUB_REF) | sed 's/refs\/heads\///')
GITHUB_SHORT_SHA := $(shell echo $(GITHUB_SHA) | cut -c1-7)
RELEASE_BRANCH := master
DOCKER_USER_ID := christophshyper
DOCKER_IMAGE := docker-terragrunt
DOCKER_NAME := $(DOCKER_USER_ID)/$(DOCKER_IMAGE)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

# Some cosmetics
SHELL := bash
define NL


endef
TXT_RED := $(shell tput setaf 1)
TXT_GREEN := $(shell tput setaf 2)
TXT_YELLOW := $(shell tput setaf 3)
TXT_RESET := $(shell tput sgr0)

.PHONY: help get-versions build build-plain build-aws build-gcp build-azure push

help: ## display help prompt
	$(info Available options:)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(TXT_YELLOW)%-25s $(TXT_RESET) %s\n", $$1, $$2}'

get-versions: ## check TF and TG versions before building
ifeq ($(TF_VERSION),latest)
	$(eval TF_VERSION = $(shell curl -s 'https://api.github.com/repos/hashicorp/terraform/releases/latest' \
    	| grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//'))
else
	$(eval TF_VERSION = $(shell curl -s 'https://api.github.com/repos/hashicorp/terraform/releases' \
        | grep '"tag_name":' | grep '$(TF_VERSION)' | head -1 | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//'))
endif
ifeq ($(TG_VERSION),latest)
	$(eval TG_VERSION = $(shell curl -s 'https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest' \
    	| grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//'))
else
	$(eval TG_VERSION = $(shell curl -s 'https://api.github.com/repos/gruntwork-io/terragrunt/releases' \
        | grep '"tag_name":' | grep '$(TG_VERSION)' | head -1 | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//'))
endif
	$(info $(NL)$(TXT_GREEN) == STARTING BUILD ==$(TXT_RESET))
	$(eval VERSION = tf-$(TF_VERSION)-tg-$(TG_VERSION))
	$(info $(TXT_GREEN)Terraform version:$(TXT_YELLOW)  $(TF_VERSION)$(TXT_RESET))
	$(info $(TXT_GREEN)Terragrunt version:$(TXT_YELLOW) $(TG_VERSION)$(TXT_RESET))
	$(info $(TXT_GREEN)Version tag:$(TXT_YELLOW)        $(VERSION)$(TXT_RESET))
	$(info $(TXT_GREEN)Current branch:$(TXT_YELLOW)     $(CURRENT_BRANCH)$(TXT_RESET))
	$(info $(TXT_GREEN)Commit hash:$(TXT_YELLOW)        $(GITHUB_SHORT_SHA)$(TXT_RESET))
	$(info $(TXT_GREEN)Build date:$(TXT_YELLOW)         $(BUILD_DATE)$(TXT_RESET))

build: get-versions build-plain build-aws ## build and push image

build-plain: ## build image without cloud CLIs
	$(info $(NL)$(TXT_GREEN)Building Docker image:$(TXT_YELLOW) $(DOCKER_NAME):$(VERSION)$(TXT_RESET))
	@docker build \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION) .

build-aws: ## build image with AWS CLI
	$(info $(NL)$(TXT_GREEN)Building Docker image:$(TXT_YELLOW) $(DOCKER_NAME):aws-$(VERSION)$(TXT_RESET))
	@docker build \
		--build-arg AWS=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):aws-$(VERSION) .

build-gcp: ## build image with GCP CLI
	$(info $(NL)$(TXT_GREEN)Building Docker image:$(TXT_YELLOW) $(DOCKER_NAME):gcp-$(VERSION)$(TXT_RESET))
	@docker build \
		--build-arg GCP=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):gcp-$(VERSION) .

build-azure: ## build image with Azure CLI
	$(info $(NL)$(TXT_GREEN)Building Docker image:$(TXT_YELLOW) $(DOCKER_NAME):azure-$(VERSION)$(TXT_RESET))
	@docker build \
		--build-arg AZURE=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):azure-$(VERSION) .

push: ## push image to DockerHub
	$(info $(NL)$(TXT_GREEN) == STARTING DEPLOYMENT == $(TXT_RESET))
	$(info $(NL)$(TXT_GREEN)Logging to DockerHub$(TXT_RESET))
	@echo $(DOCKER_TOKEN) | docker login -u $(DOCKER_USER_ID) --password-stdin
	$(info $(NL)$(TXT_GREEN)Pushing image:$(TXT_YELLOW) $(DOCKER_NAME):$(VERSION)$(TXT_RESET))
	@docker tag $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):latest
	@docker push $(DOCKER_NAME):$(VERSION)
	@docker push $(DOCKER_NAME):latest
	$(info $(NL)$(TXT_GREEN)Pushing image:$(TXT_YELLOW) $(DOCKER_NAME):aws-$(VERSION)$(TXT_RESET))
	@docker tag $(DOCKER_NAME):aws-$(VERSION) $(DOCKER_NAME):aws-latest
	@docker push $(DOCKER_NAME):aws-$(VERSION)
	@docker push $(DOCKER_NAME):aws-latest
#	$(info $(NL)$(TXT_GREEN)Pushing image:$(TXT_YELLOW) $(DOCKER_NAME):gcp-$(VERSION)$(TXT_RESET))
#	@docker tag $(DOCKER_NAME):gcp-$(VERSION) $(DOCKER_NAME):gcp-latest
#	@docker push $(DOCKER_NAME):gcp-$(VERSION)
#	@docker push $(DOCKER_NAME):gcp-latest
#	$(info $(NL)$(TXT_GREEN)Pushing image:$(TXT_YELLOW) $(DOCKER_NAME):azure-$(VERSION)$(TXT_RESET))
#	@docker tag $(DOCKER_NAME):azure-$(VERSION) $(DOCKER_NAME):azure-latest
#	@docker push $(DOCKER_NAME):azure-$(VERSION)
#	@docker push $(DOCKER_NAME):azure-latest
