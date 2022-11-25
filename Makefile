OCI = docker
# list of available arch: https://github.com/tsl0922/ttyd/releases
TARGETARCH = x86_64

default:
	@true

check: INSTALL cpanfile
	@echo Checking requirements...
	@local/bin/check.sh

ttyd: Dockerfile
	$(OCI) build . -t rojen/child-console:latest --build-arg TARGETARCH=$(TARGETARCH)
	$(OCI) run -it --rm --name child-console-ttyd -p 7681:7681 rojen/child-console:latest
