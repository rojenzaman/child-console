OCI = docker
CONTAINER = child-console-ttyd
TAG = ttyd
IMAGE = rojen/child-console:$(TAG)
# list of available arch: https://github.com/tsl0922/ttyd/releases
TARGETARCH = x86_64
MAX_CLIENTS = 10
PORT = 3003

default:
	@true

check: INSTALL cpanfile
	@echo Checking requirements...
	@local/bin/check.sh

build-container: Dockerfile
	$(OCI) build . -t $(IMAGE) --build-arg TARGETARCH=$(TARGETARCH) --build-arg MAX_CLIENTS=$(MAX_CLIENTS)

run-container:
	$(OCI) run -it --rm --name $(CONTAINER) -p $(PORT):7681 $(IMAGE)

run-container-d:
	$(OCI) run -d --name $(CONTAINER) -p $(PORT):7681 $(IMAGE)

shell:
	$(OCI) exec -it $(CONTAINER) bash

exec-child-console:
	$(OCI) exec -it $(CONTAINER) /var/lib/ttyd/child-console/console.sh

ttyd:
	make clean-container
	make build-container
	make run-container

ttyd-detached:
	make clean-container
	make build-container
	make run-container-d

clean-container:
	@docker stop $(CONTAINER) &>/dev/null || true
	@docker rm $(CONTAINER) &>/dev/null || true
