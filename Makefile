all: python
python: build-python-base build-python-dev build-python-example

build-python-base:
	docker build -t quay.io/mynth/python:base -f python/python-base.Dockerfile python

build-python-dev:
	docker build -t quay.io/mynth/python:dev -f python/python-dev.Dockerfile python

build-python-example:
	docker build -t python-example examples/python
