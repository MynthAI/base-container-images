#!/bin/sh

set -e

mkdir -p /app
cd /app || exit 1
mkdir "$1"
touch "$1"/__init__.py
poetry install --without=dev --no-interaction --no-ansi
