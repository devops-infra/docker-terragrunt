
# Provide versions of Terraform and Terragrunt to use with this Docker image
# Can be full (e.g. 0.12.16) or partial (e.g. 0.12; will get latest)
TF_VERSION ?= latest
TG_VERSION ?= latest

# Constants
GITHUB_REF ?= refs/heads/null
CURRENT_BRANCH := $(shell echo $(GITHUB_REF) | sed 's/refs\/heads\///')
RELEASE_BRANCH := master
DOCKER_NAME := krzysztofszyperepam/docker-terragrunt

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
	$(eval VERSION = $(TF_VERSION)-$(TG_VERSION))
	$(info Using Terraform version: $(TF_VERSION))
	$(info Using Terragrunt version: $(TG_VERSION))
	$(info Using branch: $(CURRENT_BRANCH))
	$(info Using version tag: $(VERSION))

docker-login:
	@docker login -u $(DOCKER_USER_ID) -p $(DOCKER_TOKEN)

docker-build: get-versions
	@docker rm $(DOCKER_NAME):latest || true
	@docker rm $(DOCKER_NAME):$(VERSION) || true
	@docker build \
		--build-arg TF_VERSION=$(TF_VERSION) \
		--build-arg TG_VERSION=$(TG_VERSION) \
ifdef GITHUB_SHORT_SHA
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
endif
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION) .

docker-push: docker-login
ifeq ($(CURRENT_BRANCH),$(RELEASE_BRANCH))
	@docker tag $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):latest
	@docker push $(DOCKER_NAME):latest
	@docker push $(DOCKER_NAME):$(VERSION)
else
	@docker tag $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-$(VERSION)
	@docker push $(DOCKER_NAME):$(CURRENT_BRANCH)-latest
	@docker push $(DOCKER_NAME):$(CURRENT_BRANCH)-$(VERSION)
endif

build-and-push: docker-build docker-push
