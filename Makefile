
# Provide versions of Terraform and Terragrunt to use with this Docker image
# Can be full (e.g. 0.12.18) or partial (e.g. 0.12 - which will get latest in that family)
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
export XTERM := xterm256
define nl


endef
TXT_RED := $(shell tput setaf 1)
TXT_GREEN := $(shell tput setaf 2)
TXT_YELLOW := $(shell tput setaf 3)
TXT_RESET := $(shell tput sgr0)

get-versions:
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
	$(info $(nl)$(TXT_GREEN) == STARTING BUILD == $(TXT_RESET))
	$(eval VERSION = tf-$(TF_VERSION)-tg-$(TG_VERSION))
	$(info $(TXT_YELLOW)Terraform version:$(TXT_RESET) $(TF_VERSION))
	$(info $(TXT_YELLOW)Terragrunt version:$(TXT_RESET) $(TG_VERSION))
	$(info $(TXT_YELLOW)Version tag:$(TXT_RESET) $(VERSION))
	$(info $(TXT_YELLOW)Current branch:$(TXT_RESET) $(CURRENT_BRANCH))
	$(info $(TXT_YELLOW)Commit hash:$(TXT_RESET) $(GITHUB_SHORT_SHA))
	$(info $(TXT_YELLOW)Build date:$(TXT_RESET) $(BUILD_DATE))

docker-build: get-versions docker-build-plain docker-build-aws

docker-build-plain:
	$(info $(nl)$(TXT_YELLOW)Building Docker image:$(TXT_RESET) $(DOCKER_NAME):$(VERSION))
	@docker build \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION) .

docker-build-aws:
	$(info $(nl)$(TXT_YELLOW)Building Docker image:$(TXT_RESET) $(DOCKER_NAME):aws-$(VERSION))
	@docker build \
		--build-arg AWS=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):aws-$(VERSION) .

docker-build-gcp:
	$(info $(nl)$(TXT_YELLOW)Building Docker image:$(TXT_RESET) $(DOCKER_NAME):gcp-$(VERSION))
	@docker build \
		--build-arg GCP=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):gcp-$(VERSION) .

docker-build-azure:
	$(info $(nl)$(TXT_YELLOW)Building Docker image:$(TXT_RESET) $(DOCKER_NAME):azure-$(VERSION))
	@docker build \
		--build-arg AZURE=yes \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):azure-$(VERSION) .

docker-login:
	@echo $(DOCKER_TOKEN) | docker login -u $(DOCKER_USER_ID) --password-stdin

docker-push: docker-login
	$(info $(nl)$(TXT_GREEN) == STARTING DEPLOYMENT == $(TXT_RESET))
ifeq ($(CURRENT_BRANCH),$(RELEASE_BRANCH))
	$(info $(TXT_YELLOW)Using image:$(TXT_RESET) $(DOCKER_NAME):$(VERSION))
	@docker tag $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):latest
	$(info $(TXT_YELLOW)Using image:$(TXT_RESET) $(DOCKER_NAME):aws-$(VERSION))
	@docker tag $(DOCKER_NAME):aws-$(VERSION) $(DOCKER_NAME):aws-latest
#	$(info $(TXT_YELLOW)Using image:$(TXT_RESET) $(DOCKER_NAME):gcp-$(VERSION))
#	@docker tag $(DOCKER_NAME):gcp-$(VERSION) $(DOCKER_NAME):gcp-latest
#	$(info $(TXT_YELLOW)Using image:$(TXT_RESET) $(DOCKER_NAME):azure-$(VERSION))
#	@docker tag $(DOCKER_NAME):azure-$(VERSION) $(DOCKER_NAME):azure-latest
	@docker push $(DOCKER_NAME)
	@docker rmi $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):latest || true
	@docker rmi $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(VERSION) || true
	@docker rmi $(DOCKER_NAME):aws-$(VERSION) $(DOCKER_NAME):aws-latest || true
	@docker rmi $(DOCKER_NAME):aws-$(VERSION) $(DOCKER_NAME):aws-$(VERSION) || true
#	@docker rmi $(DOCKER_NAME):gcp-$(VERSION) $(DOCKER_NAME):gcp-latest || true
#	@docker rmi $(DOCKER_NAME):gcp-$(VERSION) $(DOCKER_NAME):gcp-$(VERSION) || true
#	@docker rmi $(DOCKER_NAME):azure-$(VERSION) $(DOCKER_NAME):azure-latest || true
#	@docker rmi $(DOCKER_NAME):azure-$(VERSION) $(DOCKER_NAME):azure-$(VERSION) || true
else
	$(info $(TXT_YELLOW)Using image:$(TXT_RESET) $(DOCKER_NAME):$(CURRENT_BRANCH)-$(VERSION))
	@docker tag $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-$(VERSION)
	$(info $(TXT_YELLOW)Using image:$(TXT_RESET) $(DOCKER_NAME):$(CURRENT_BRANCH)-latest)
	@docker tag $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-latest
	$(info $(TXT_YELLOW)Using image:$(TXT_RESET) $(DOCKER_NAME):$(CURRENT_BRANCH)-aws-$(VERSION))
	@docker tag $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-aws-$(VERSION)
	$(info $(TXT_YELLOW)Using image:$(TXT_RESET) $(DOCKER_NAME):$(CURRENT_BRANCH)-aws-latest)
	@docker tag $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-aws-latest
#	$(info $(TXT_YELLOW)Using image:$(TXT_RESET) $(DOCKER_NAME):$(CURRENT_BRANCH)-gcp-$(VERSION))
#	@docker tag $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-gcp-$(VERSION)
#	$(info $(TXT_YELLOW)Using image:$(TXT_RESET) $(DOCKER_NAME):$(CURRENT_BRANCH)-gcp-latest)
#	@docker tag $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-gcp-latest
#	$(info $(TXT_YELLOW)Using image:$(TXT_RESET) $(DOCKER_NAME):$(CURRENT_BRANCH)-azure-$(VERSION))
#	@docker tag $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-azure-$(VERSION)
#	$(info $(TXT_YELLOW)Using image:$(TXT_RESET) $(DOCKER_NAME):$(CURRENT_BRANCH)-azure-latest)
#	@docker tag $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-azure-latest
	@docker push $(DOCKER_NAME)
	@docker rmi $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-$(VERSION) || true
	@docker rmi $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-latest || true
	@docker rmi $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-aws-$(VERSION) || true
	@docker rmi $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-aws-latest || true
#	@docker rmi $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-gcp-$(VERSION) || true
#	@docker rmi $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-gcp-latest || true
#	@docker rmi $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-azure-$(VERSION) || true
#	@docker rmi $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-azure-latest || true
	@docker rmi $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(VERSION) || true
endif

build-and-push: docker-build docker-push
