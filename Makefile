all: node
node: build-node-18-base build-node-18-dev build-node-example

build-node-18-base:
	docker build -t quay.io/mynth/node:18-base -f node-18/node-base.Dockerfile node-18

build-node-18-dev:
	docker build -t quay.io/mynth/node:18-dev -f node-18/node-dev.Dockerfile node-18

build-node-example:
	docker build -t node-example examples/node
