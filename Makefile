all: node-22 python
node-22: build-node-22-base build-node-22-dev build-node-22-example
python: build-python-base build-python-dev build-python-example

build-node-22-base:
	docker build -t quay.io/mynth/node:22-base -f node-22/node-base.Dockerfile node-22

build-node-22-dev:
	docker build -t quay.io/mynth/node:22-dev -f node-22/node-dev.Dockerfile node-22

build-node-22-example:
	docker build -t node-22-example examples/node-22

build-python-base:
	docker build -t quay.io/mynth/python:base -f python/python-base.Dockerfile python

build-python-dev:
	docker build -t quay.io/mynth/python:dev -f python/python-dev.Dockerfile python

build-python-example:
	docker build -t python-example examples/python