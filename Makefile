PWD=$(shell pwd)

IMAGE=stayallive/hera
BUILDER_IMAGE=$(IMAGE)-builder

default: build run

release: build push

build:
	docker build -t $(IMAGE) .

test:
	docker build --target builder -t $(BUILDER_IMAGE) .
	docker run --rm -e CGO_ENABLED=0 $(BUILDER_IMAGE) go test

run:
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $(PWD)/.certs:/certs --network=hera $(IMAGE)

.PHONY:tunnel
tunnel:
	docker run --rm --label hera.hostname=$(HOSTNAME) --label hera.port=80 --network=hera nginx

release:
	docker buildx build -t $(IMAGE) . --platform=linux/amd64 --push
