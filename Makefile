
# Provide versions of Terraform and Terragrunt to use with this Docker image
TF_VERSION ?= 0.12.16
TG_VERSION ?= 0.21.6

# Constants
CURRENT_BRANCH := ${bamboo_planRepository_branchName}
RELEASE_BRANCH := master
DOCKER_NAME := krzysztofszyperepam/docker-terragrunt

# Version tag taken from environment, file, or calculated date
VERSION_FILE := version.txt
ifdef VERSION
  $(shell echo "version=$(VERSION)" > $(VERSION_FILE))
  $(info using version $(VERSION) from parameter input or environment)
else ifneq ("$(wildcard $(VERSION_FILE))","")
  VERSION=$(shell awk -F'=' '/version/{print $$2}' $(VERSION_FILE))
  $(info using version $(VERSION) from file $(VERSION_FILE))
else
  VERSION=$(shell date -u +"%Y-%m-%dT%H-%M-%SZ")
  $(shell echo "version=$(VERSION)" > $(VERSION_FILE))
  $(info using version $(VERSION) which is self-calculated)
endif

test:
	@echo version: $(VERSION)

clean:
	rm -f $(VERSION_FILE)

docker-create:
	docker rm $(DOCKER_NAME):latest || true
	docker build \
	  --build-arg TF_VERSION=$(TF_VERSION) \
	  --build-arg TG_VERSION=$(TG_VERSION) \
      --file=Dockerfile \
      --tag=$(DOCKER_NAME):$(VERSION) .

docker-push:
ifeq ($(CURRENT_BRANCH),$(RELEASE_BRANCH))
	docker tag $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):latest
	docker push $(DOCKER_NAME):$(VERSION)
	docker push $(DOCKER_NAME):latest
else
	docker tag $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):$(CURRENT_BRANCH)-$(VERSION)
	docker push $(DOCKER_NAME):$(CURRENT_BRANCH)-$(VERSION)
endif

build-deploy: clean docker-create docker-push
