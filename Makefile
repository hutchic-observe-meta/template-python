IMAGE_NAME ?= $(notdir $(CURDIR))
CONTAINER_BASE_NAME ?= $(notdir $(CURDIR))
CONTAINER_NAME ?= $(CONTAINER_BASE_NAME)-$(PROVIDER)
UID := $(shell id -u)
GID := $(shell id -g)
DOCKER_COMMAND ?= /bin/bash

.PHONY: docker/clean
docker/clean: docker/test/clean
	docker kill $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true
	docker rmi -f $(IMAGE_NAME) || true

.PHONY: docker/build
docker/build:
	docker build --build-arg UID=$(UID) --build-arg GID=$(GID) --build-arg USER=$(USER) -t $(IMAGE_NAME) .

.PHONY: docker/%
docker/%:
	$(MAKE) docker/run DOCKER_COMMAND="make $*"

.PHONY: docker/run
docker/run: docker/build
	@if [ -z "`docker ps -q -f name=$(CONTAINER_NAME)`" ]; then \
		echo "Container is not running. Starting a new one."; \
		docker run -it --rm \
		--name $(CONTAINER_NAME) \
		-e USER=$(USER) \
		-v $(PWD):/workdir \
		-u $(UID):$(GID) \
		$(IMAGE_NAME) $(DOCKER_COMMAND); \
	else \
		echo "Container is already running. Executing command inside the container."; \
		docker exec -it $(CONTAINER_NAME) $(DOCKER_COMMAND); \
	fi
