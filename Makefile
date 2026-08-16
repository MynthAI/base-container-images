all: node-24 python
node-24: build-node-24-base build-node-24-dev build-node-24-example
python: build-python-base build-python-dev build-python-example

build-node-24-base:
	docker build -t quay.io/mynth/node:24-base -f node-24/node-base.Dockerfile node-24

build-node-24-dev:
	docker build -t quay.io/mynth/node:24-dev -f node-24/node-dev.Dockerfile node-24

build-node-24-example:
	docker build -t node-24-example examples/node-24

build-python-base:
	docker build -t quay.io/mynth/python:base -f python/python-base.Dockerfile python

build-python-dev:
	docker build -t quay.io/mynth/python:dev -f python/python-dev.Dockerfile python

build-python-example:
	docker build -t python-example examples/python
