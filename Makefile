all: node-26 python worker
node-26: build-node-26-base build-node-26-dev build-node-26-example
python: build-python-base build-python-dev build-python-example
worker: build-worker build-worker-example

build-node-26-base:
	docker build -t quay.io/mynth/node:26-base -f node-26/node-base.Dockerfile node-26

build-node-26-dev:
	docker build -t quay.io/mynth/node:26-dev -f node-26/node-dev.Dockerfile node-26

build-node-26-example:
	docker build -t node-26-example examples/node-26

build-python-base:
	docker build -t quay.io/mynth/python:base -f python/python-base.Dockerfile python

build-python-dev:
	docker build -t quay.io/mynth/python:dev -f python/python-dev.Dockerfile python

build-python-example:
	docker build -t python-example examples/python

build-worker:
	docker build -t quay.io/mynth/worker:26 -f worker/worker.Dockerfile .

build-worker-example:
	docker build -t worker-example examples/worker
