all: python node
python: build-python-base build-python-dev build-python-example
node: build-node-base build-node-dev build-node-18-base build-node-18-dev build-node-example

build-python-base:
	docker build -t quay.io/mynth/python:base -f python/python-base.Dockerfile python

build-python-dev:
	docker build -t quay.io/mynth/python:dev -f python/python-dev.Dockerfile python

build-python-example:
	docker build -t python-example examples/python

build-node-base:
	docker build -t quay.io/mynth/node:base -f node/node-base.Dockerfile node

build-node-dev:
	docker build -t quay.io/mynth/node:dev -f node/node-dev.Dockerfile node

build-node-18-base:
	docker build -t quay.io/mynth/node:18-base -f node-18/node-base.Dockerfile node-18

build-node-18-dev:
	docker build -t quay.io/mynth/node:18-dev -f node-18/node-dev.Dockerfile node-18

build-node-example:
	docker build -t node-example examples/node
