.PHONY: all build-base build-dev build-example

all: build-base build-dev build-example

build-base:
	docker build -t quay.io/mynth/python:base -f python/python-base.Dockerfile python

build-dev:
	docker build -t quay.io/mynth/python:dev -f python/python-dev.Dockerfile python

build-example:
	docker build -t python-example examples/python
