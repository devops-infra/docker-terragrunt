.PHONY: phony
phony: help

# Provide versions of the main dependencies to use with this Docker image
AWS_VERSION := 2.11.18
GCP_VERSION := 429.0.0
TF_VERSION := 1.4.6
TG_VERSION := 0.45.10

# GitHub Actions bogus variables
GITHUB_REF ?= refs/heads/null
GITHUB_SHA ?= aabbccddeeff
VERSION_PREFIX ?=

# Set version tags
TF_LATEST := $(shell curl -LsS https://api.github.com/repos/hashicorp/terraform/releases/latest | jq -r .tag_name | sed 's/^v//')
TG_LATEST := $(shell curl -LsS https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r .tag_name | sed 's/^v//')
VERSION := tf-$(TF_VERSION)-tg-$(TG_VERSION)
VERSION_LATEST := tf-$(TF_LATEST)-tg-$(TG_LATEST)
AWS_LATEST := $(shell curl -LsS https://api.github.com/repos/aws/aws-cli/tags | jq -r .[].name | head -1)
GCP_LATEST := $(shell curl -LsS https://cloud.google.com/sdk/docs/install | grep -e "curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli" | head -1 | sed 's/curl.*cli-//; s/-linux.*//')

# Other variables and constants
CURRENT_BRANCH := $(shell echo $(GITHUB_REF) | sed 's/refs\/heads\///')
GITHUB_SHORT_SHA := $(shell echo $(GITHUB_SHA) | cut -c1-7)
DOCKER_USER_ID := christophshyper
DOCKER_ORG_NAME := devopsinfra
DOCKER_IMAGE := docker-terragrunt
DOCKER_NAME := $(DOCKER_ORG_NAME)/$(DOCKER_IMAGE)
GITHUB_USER_ID := ChristophShyper
GITHUB_ORG_NAME := devops-infra
GITHUB_NAME := ghcr.io/$(GITHUB_ORG_NAME)/$(DOCKER_IMAGE)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
FLAVOURS := aws azure aws-azure gcp aws-gcp azure-gcp aws-azure-gcp yc

# Recognize whether docker buildx is installed or not
DOCKER_CHECK := $(shell docker buildx version 1>&2 2>/dev/null; echo $$?)
ifeq ($(DOCKER_CHECK),0)
DOCKER_COMMAND := docker buildx build --platform linux/amd64,linux/arm64
else
DOCKER_COMMAND := docker build
endif

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


.PHONY: check-dockerfile
check-dockerfile: ## Temporarily updates Makefile if buildx is not available, preventing build errors
	$(info Checking Makefile)
	@if [[ "$(DOCKER_COMMAND)" == "docker build" ]]; then \
		echo Docker buildx not available, simplyfing ;\
		sed -i 's/--platform=\$${BUILDPLATFORM}//' Dockerfile  ;\
	fi


.PHONY: update-versions
update-versions: ## Check TF and TG versions and update if there's new
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
	@if [[ $(TF_VERSION) != $(TF_LATEST) ]] || [[ $(TG_VERSION) != $(TG_LATEST) ]] || [[ $(AWS_VERSION) != $(AWS_LATEST) ]] || [[ $(GCP_VERSION) != $(GCP_LATEST) ]]; then \
  		echo -e "\n$(TXT_YELLOW) == UPDATING VERSIONS ==$(TXT_RESET)" ;\
  		echo "VERSION_TAG=$(VERSION_LATEST)-aws-$(AWS_LATEST)-gcp-$(GCP_LATEST)" >> $(GITHUB_ENV) ;\
  	else \
  	  	echo "VERSION_TAG=null" >> $(GITHUB_ENV) ;\
  	fi


.PHONY: build-all
build-all: build-plain build-aws build-azure build-aws-azure build-gcp build-aws-gcp build-azure-gcp build-aws-azure-gcp ## Build all Docker images one by one


.PHONY: build-parallel
build-parallel: check-dockerfile ## Build all image in parallel
	# build plain image first so unconditional layers can be reused
	@make -s build-slim VERSION_PREFIX=$(VERSION_PREFIX)
	@make -s build-plain VERSION_PREFIX=$(VERSION_PREFIX)
	@for FL in $(FLAVOURS); do \
			make -s build-$$FL VERSION_PREFIX=$(VERSION_PREFIX) &\
		done ;\
		wait


.PHONY: build-slim
build-slim: check-dockerfile ## Build slim image without cloud CLIs and any additional software
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)slim-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg SLIM=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)slim-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)slim-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)slim-$(VERSION) \
        --tag=$(GITHUB_NAME):$(VERSION_PREFIX)slim-latest .


.PHONY: build-plain
build-plain: check-dockerfile ## Build image without cloud CLIs
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)$(VERSION) \
        --tag=$(GITHUB_NAME):$(VERSION_PREFIX)latest .


.PHONY: build-aws
build-aws: check-dockerfile ## Build image with AWS CLI
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-latest .


.PHONY: build-azure
build-azure: check-dockerfile ## Build image with Azure CLI
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg AZURE=yes \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-latest .


.PHONY: build-aws-azure
build-aws-azure: check-dockerfile ## Build image with AWS and Azure CLI
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg AZURE=yes \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-latest .


.PHONY: build-gcp
build-gcp: check-dockerfile ## Build image with GCP CLI
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)gcp-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)gcp-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)gcp-latest .


.PHONY: build-aws-gcp
build-aws-gcp: check-dockerfile ## Build image with AWS and GCP CLI
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-gcp-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-gcp-latest .


.PHONY: build-azure-gcp
build-azure-gcp: check-dockerfile ## Build image with Azure and GCP CLI
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg AZURE=yes \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-gcp-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-gcp-latest .


.PHONY: build-aws-azure-gcp
build-aws-azure-gcp: check-dockerfile ## Build image with AWS, Azure and GCP CLI
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg AZURE=yes \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-gcp-latest .


.PHONY: build-yc
build-yc: check-dockerfile ## Build image with YandexCloud CLI
	$(info $(NL)$(TXT_GREEN)Building image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)yc-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) \
		--build-arg YC=yes \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)yc-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)yc-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)yc-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)yc-latest .


.PHONY: login
login: ## Log into all registries
	@echo -e "\n$(TXT_GREEN)Logging to: $(TXT_YELLOW)Docker Hub$(TXT_RESET)"
	@echo $(DOCKER_TOKEN) | docker login -u $(DOCKER_USER_ID) --password-stdin
	@echo -e "\n$(TXT_GREEN)Logging to: $(TXT_YELLOW)GitHub Packages$(TXT_RESET)"
	@echo $(GITHUB_TOKEN) | docker login ghcr.io -u $(GITHUB_USER_ID) --password-stdin


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
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)slim-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg SLIM=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)slim-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)slim-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)slim-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)slim-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_IMAGE):$(VERSION_PREFIX)slim-$(VERSION)$(TXT_RESET)"


.PHONY: push-plain
push-plain: login ## Push only plain image
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_IMAGE):$(VERSION_PREFIX)$(VERSION)$(TXT_RESET)"


.PHONY: push-aws
push-aws: login ## Push image with AWS CLI
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-$(VERSION)$(TXT_RESET)"


.PHONY: push-azure
push-azure: login ## Push image with Azure CLI
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg AZURE=yes \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-$(VERSION)$(TXT_RESET)"


.PHONY: push-aws-azure
push-aws-azure: login ## Push image with AWS and Azure CLI
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg AZURE=yes \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-$(VERSION)$(TXT_RESET)"


.PHONY: push-gcp
push-gcp: login ## Push image with GCP CLI
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)gcp-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)gcp-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)gcp-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)gcp-$(VERSION)$(TXT_RESET)"


.PHONY: push-aws-gcp
push-aws-gcp: login ## Push image with AWS and GCP CLI
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-gcp-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-gcp-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-gcp-$(VERSION)$(TXT_RESET)"


.PHONY: push-azure-gcp
push-azure-gcp: login ## Push image with Azure and GCP CLI
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg AZURE=yes \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-gcp-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)azure-gcp-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)azure-gcp-$(VERSION)$(TXT_RESET)"


.PHONY: push-aws-azure-gcp
push-aws-azure-gcp: login ## Push image with AWS, Azure and GCP CLI
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg AWS=yes \
		--build-arg AWS_VERSION=$(AWS_VERSION) \
		--build-arg AZURE=yes \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg GCP=yes \
		--build-arg GCP_VERSION=$(GCP_VERSION) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)aws-azure-gcp-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)aws-azure-gcp-$(VERSION)$(TXT_RESET)"


.PHONY: push-yc
push-yc: login ## Push image with YandexCloud CLI
	$(info $(NL)$(TXT_GREEN)Building and pushing image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)yc-$(VERSION)$(TXT_RESET)$(NL))
	@$(DOCKER_COMMAND) --push \
		--build-arg YC=yes \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)yc-$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)yc-latest \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)yc-$(VERSION) \
		--tag=$(GITHUB_NAME):$(VERSION_PREFIX)yc-latest .
	@echo -e "\n$(TXT_GREEN)Pushed image: $(TXT_YELLOW)$(DOCKER_NAME):$(VERSION_PREFIX)yc-$(VERSION)$(TXT_RESET)"
