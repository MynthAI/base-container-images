all: node
node: build-node-base build-node-dev build-node-example

build-node-base:
	docker build -t quay.io/mynth/node:base -f node/node-base.Dockerfile node

build-node-dev:
	docker build -t quay.io/mynth/node:dev -f node/node-dev.Dockerfile node

build-node-example:
	docker build -t node-example examples/node
