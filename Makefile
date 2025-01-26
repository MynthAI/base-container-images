all: node-18 python node
node-18: build-node-18-base build-node-18-dev build-node-18-example
node-20: build-node-20-base build-node-20-dev build-node-20-example
node-22: build-node-22-base build-node-22-dev build-node-22-example
node: build-node-base build-node-dev build-node-example
python: build-python-base build-python-dev build-python-example

build-node-base:
	docker build -t quay.io/mynth/node:base -f node/node-base.Dockerfile node

build-node-dev:
	docker build -t quay.io/mynth/node:dev -f node/node-dev.Dockerfile node

build-node-example:
	docker build -t node-example examples/node

build-node-18-base:
	docker build -t quay.io/mynth/node:18-base -f node-18/node-base.Dockerfile node-18

build-node-18-dev:
	docker build -t quay.io/mynth/node:18-dev -f node-18/node-dev.Dockerfile node-18

build-node-18-example:
	docker build -t node-18-example examples/node-18

build-node-20-base:
	docker build -t quay.io/mynth/node:20-base -f node-20/node-base.Dockerfile node-20

build-node-20-dev:
	docker build -t quay.io/mynth/node:20-dev -f node-20/node-dev.Dockerfile node-20

build-node-20-example:
	docker build -t node-20-example examples/node-20

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