all: node-22 node-24
node-22: build-node-22-base build-node-22-dev build-node-22-example
node-24: build-node-24-base build-node-24-dev build-node-24-example

build-node-22-base:
	docker build -t quay.io/mynth/node:22-base -f node-22/node-base.Dockerfile node-22

build-node-22-dev:
	docker build -t quay.io/mynth/node:22-dev -f node-22/node-dev.Dockerfile node-22

build-node-22-example:
	docker build -t node-22-example examples/node-22

build-node-24-base:
	docker build -t quay.io/mynth/node:24-base -f node-24/node-base.Dockerfile node-24

build-node-24-dev:
	docker build -t quay.io/mynth/node:24-dev -f node-24/node-dev.Dockerfile node-24

build-node-24-example:
	docker build -t node-24-example examples/node-24
