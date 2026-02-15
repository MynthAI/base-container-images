all: node-24
node-24: build-node-24-base build-node-24-dev build-node-24-example

build-node-24-base:
	docker build -t quay.io/mynth/node:24-base -f node-24/node-base.Dockerfile node-24

build-node-24-dev:
	docker build -t quay.io/mynth/node:24-dev -f node-24/node-dev.Dockerfile node-24

build-node-24-example:
	docker build -t node-24-example examples/node-24
