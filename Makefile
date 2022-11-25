OCI = docker
CONTAINER = child-console-ttyd
# list of available arch: https://github.com/tsl0922/ttyd/releases
TARGETARCH = x86_64

default:
	@true

check: INSTALL cpanfile
	@echo Checking requirements...
	@local/bin/check.sh

build-container: Dockerfile
	$(OCI) build . -t rojen/child-console:latest --build-arg TARGETARCH=$(TARGETARCH)

run-container:
	$(OCI) run -it --rm --name $(CONTAINER) -p 7681:7681 rojen/child-console:latest

run-container-d:
	$(OCI) run -d --name $(CONTAINER) -p 7681:7681 rojen/child-console:latest

ttyd:
	@make clean-container
	make build-container
	make run-container

ttyd-detached:
	@make clean-container
	make build-container
	make run-container-d

clean-container:
	@docker stop $(CONTAINER) &>/dev/null || true
	@docker rm $(CONTAINER) &>/dev/null || true
