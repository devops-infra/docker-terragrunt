.PHONY: phony
phony: help

# Provide versions of Terraform and Terragrunt to use with this Docker image
TF_VERSION := 1.0.7
TG_VERSION := 0.32.3

# GitHub Actions bogus variables
GITHUB_REF ?= refs/heads/null
GITHUB_SHA ?= aabbccddeeff
VERSION_PREFIX ?=

# Set version tags
TF_LATEST := $(shell curl -s 'https://api.github.com/repos/hashicorp/terraform/releases/latest' | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
TG_LATEST := $(shell curl -s 'https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest' | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
VERSION := tf-$(TF_VERSION)-tg-$(TG_VERSION)
VERSION_LATEST := tf-$(TF_LATEST)-tg-$(TG_LATEST)

# Other variables and constants
CURRENT_BRANCH := $(shell echo $(GITHUB_REF) | sed 's/refs\/heads\///')
GITHUB_SHORT_SHA := $(shell echo $(GITHUB_SHA) | cut -c1-7)
DOCKER_USER_ID := christophshyper
DOCKER_ORG_NAME := devopsinfra
DOCKER_IMAGE := docker-terragrunt
DOCKER_NAME := $(DOCKER_ORG_NAME)/$(DOCKER_IMAGE)
GITHUB_USER_ID := ChristophShyper
GITHUB_ORG_NAME := devops-infra
GITHUB_NAME := docker.pkg.github.com/$(GITHUB_ORG_NAME)/$(DOCKER_IMAGE)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
FLAVOURS := aws azure aws-azure gcp aws-gcp azure-gcp aws-azure-gcp

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
update-versions: ## Check TF and TG versions and update if there's new
	$(info $(NL)$(TXT_GREEN) == CURRENT VERSIONS ==$(TXT_RESET))
	$(info $(TXT_GREEN)Current Terraform:$(TXT_YELLOW)  $(TF_VERSION)$(TXT_RESET))
	$(info $(TXT_GREEN)Current Terragrunt:$(TXT_YELLOW) $(TG_VERSION)$(TXT_RESET))
	$(info $(TXT_GREEN)Current tag:$(TXT_YELLOW)        $(VERSION)$(TXT_RESET))
	@if [[ $(VERSION) != $(VERSION_LATEST) ]]; then \
  		echo -e "\n$(TXT_YELLOW) == UPDATING VERSIONS ==$(TXT_RESET)"; \
  		echo -e "$(TXT_GREEN)Latest Terraform:$(TXT_YELLOW)     $(TF_LATEST)$(TXT_RESET)"; \
  		echo -e "$(TXT_GREEN)Latest Terragrunt:$(TXT_YELLOW)    $(TG_LATEST)$(TXT_RESET)"; \
  		echo -e "$(TXT_GREEN)Latest tag:$(TXT_YELLOW)           $(VERSION_LATEST)$(TXT_RESET)"; \
  		echo "VERSION_TAG=$(VERSION_LATEST)" >> $(GITHUB_ENV) ; \
		find . -type f -name "*" -print0 | xargs -0 sed -i "s/$(TG_VERSION)/$(TG_LATEST)/g"; \
		find . -type f -name "*" -print0 | xargs -0 sed -i "s/$(TF_VERSION)/$(TF_LATEST)/g"; \
	else \
		echo "VERSION_TAG=null" >> $(GITHUB_ENV) ; \
		echo -e "\n$(TXT_YELLOW) == NO CHANGES NEEDED ==$(TXT_RESET)"; \
	fi


.PHONY: build-all
build-all: build-plain build-aws build-azure build-aws-azure build-gcp build-aws-gcp build-azure-gcp build-aws-azure-gcp ## Build all Docker images one by one


.PHONY: build-parallel
build-parallel: ## Build all image in parallel
	# build plain image first so unconditional layers can be reused
	@make -s build-plain VERSION_PREFIX=$(VERSION_PREFIX)
	@for FL in $(FLAVOURS); do \
			make -s build-$$FL VERSION_PREFIX=$(VERSION_PREFIX) &\
		done ;\
		wait


.PHONY: build-plain
build-plain: ## Build image without cloud CLIs
	$(info $(NL)$(TXT_GREEN)Building Docker image:$(TXT_YELLOW) $(DOCKER_NAME):$(VERSION_PREFIX)$(VERSION)$(TXT_RESET)$(NL))
	@docker build \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)latest .


.PHONY: build-aws
build-aws: ## Build image with AWS CLI
	$(info $(NL)$(TXT_GREEN)Building Docker image:$(TXT_YELLOW) $(DOCKER_NAME):$(VERSION_PREFIX)aws-$(VERSION)$(TXT_RESET)$(NL))
	@docker build \
		--build-arg AWS=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-latest .


.PHONY: build-azure
build-azure: ## Build image with Azure CLI
	$(info $(NL)$(TXT_GREEN)Building Docker image:$(TXT_YELLOW) $(DOCKER_NAME):$(VERSION_PREFIX)azure-$(VERSION)$(TXT_RESET)$(NL))
	@docker build \
		--build-arg AZURE=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-latest .


.PHONY: build-aws-azure
build-aws-azure: ## Build image with AWS and Azure CLI
	$(info $(NL)$(TXT_GREEN)Building Docker image:$(TXT_YELLOW) $(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(VERSION)$(TXT_RESET)$(NL))
	@docker build \
		--build-arg AWS=yes \
		--build-arg AZURE=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-latest .


.PHONY: build-gcp
build-gcp: ## Build image with GCP CLI
	$(info $(NL)$(TXT_GREEN)Building Docker image:$(TXT_YELLOW) $(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(VERSION)$(TXT_RESET)$(NL))
	@docker build \
		--build-arg GCP=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)gcp-latest .


.PHONY: build-aws-gcp
build-aws-gcp: ## Build image with AWS and GCP CLI
	$(info $(NL)$(TXT_GREEN)Building Docker image:$(TXT_YELLOW) $(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(VERSION)$(TXT_RESET)$(NL))
	@docker build \
		--build-arg AWS=yes \
		--build-arg GCP=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-latest .


.PHONY: build-azure-gcp
build-azure-gcp: ## Build image with Azure and GCP CLI
	$(info $(NL)$(TXT_GREEN)Building Docker image:$(TXT_YELLOW) $(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(VERSION)$(TXT_RESET)$(NL))
	@docker build \
		--build-arg AZURE=yes \
		--build-arg GCP=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-latest .


.PHONY: build-aws-azure-gcp
build-aws-azure-gcp: ## Build image with AWS, Azure and GCP CLI
	$(info $(NL)$(TXT_GREEN)Building Docker image:$(TXT_YELLOW) $(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(VERSION)$(TXT_RESET)$(NL))
	@docker build \
		--build-arg AWS=yes \
		--build-arg AZURE=yes \
		--build-arg GCP=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-latest .


.PHONY: login
login: ## Log into all registries
	@echo -e "\n$(TXT_GREEN)Logging to: $(TXT_YELLOW)Docker Hub$(TXT_RESET)"
	@echo $(DOCKER_TOKEN) | docker login -u $(DOCKER_USER_ID) --password-stdin
	@echo -e "\n$(TXT_GREEN)Logging to: $(TXT_YELLOW)GitHub Packages$(TXT_RESET)"
	@echo $(GITHUB_TOKEN) | docker login https://docker.pkg.github.com -u $(GITHUB_USER_ID) --password-stdin


.PHONY: push-plain
push-plain: ## Push only plain image, logging into registries beforehand is required
	@echo -e "\n$(TXT_GREEN)Pushing image: $(TXT_YELLOW)$(DOCKER_IMAGE):$(VERSION_PREFIX)$(VERSION)$(TXT_RESET)"
	@docker tag $(DOCKER_NAME):$(VERSION_PREFIX)$(VERSION) $(DOCKER_NAME):$(VERSION_PREFIX)latest
	@docker tag $(DOCKER_NAME):$(VERSION_PREFIX)$(VERSION) $(GITHUB_NAME)/$(DOCKER_IMAGE):$(VERSION_PREFIX)$(VERSION)
	@docker tag $(DOCKER_NAME):$(VERSION_PREFIX)$(VERSION) $(GITHUB_NAME)/$(DOCKER_IMAGE):$(VERSION_PREFIX)latest
	@docker push $(DOCKER_NAME):$(VERSION_PREFIX)$(VERSION) &\
		docker push $(DOCKER_NAME):$(VERSION_PREFIX)latest &\
		docker push $(GITHUB_NAME)/$(DOCKER_IMAGE):$(VERSION_PREFIX)$(VERSION) &\
		docker push $(GITHUB_NAME)/$(DOCKER_IMAGE):$(VERSION_PREFIX)latest &\
		wait ;\
		echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_IMAGE):$(VERSION_PREFIX)$(VERSION)$(TXT_RESET)"


.PHONY: push-target
push-target: ## Push single image flavour defined by TARGET var, logging into registries beforehand is required
	@echo -e "\n$(TXT_GREEN)Pushing image: $(TXT_YELLOW)$(DOCKER_IMAGE):$(VERSION_PREFIX)$(TARGET)-$(VERSION)$(TXT_RESET)"
	@docker tag $(DOCKER_NAME):$(VERSION_PREFIX)$(TARGET)-$(VERSION) $(DOCKER_NAME):$(VERSION_PREFIX)$(TARGET)-latest
	@docker tag $(DOCKER_NAME):$(VERSION_PREFIX)$(TARGET)-$(VERSION) $(GITHUB_NAME)/$(DOCKER_IMAGE):$(VERSION_PREFIX)$(TARGET)-$(VERSION)
	@docker tag $(DOCKER_NAME):$(VERSION_PREFIX)$(TARGET)-$(VERSION) $(GITHUB_NAME)/$(DOCKER_IMAGE):$(VERSION_PREFIX)$(TARGET)-latest
	@docker push $(DOCKER_NAME):$(VERSION_PREFIX)$(TARGET)-$(VERSION) &\
		docker push $(DOCKER_NAME):$(VERSION_PREFIX)$(TARGET)-latest &\
		docker push $(GITHUB_NAME)/$(DOCKER_IMAGE):$(VERSION_PREFIX)$(TARGET)-$(VERSION) &\
		docker push $(GITHUB_NAME)/$(DOCKER_IMAGE):$(VERSION_PREFIX)$(TARGET)-latest &\
		wait ;\
		echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_IMAGE):$(VERSION_PREFIX)$(TARGET)-$(VERSION)$(TXT_RESET)"


.PHONY: push-parallel
push-parallel: ## Push all images in parallel
	$(info $(NL)$(TXT_GREEN) == STARTING DEPLOYMENT TO ALL REGISTRIES == $(TXT_RESET)$(NL))
	@make -s login
	@make -s push-plain
	@for FL in $(FLAVOURS); do \
			make -s push-target TARGET=$$FL &\
			wait ;\
		done
