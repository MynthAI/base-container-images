#!/bin/sh

set -e

mkdir -p /app
cd /app || exit 1
mkdir "$1"
touch "$1"/__init__.py
uv sync --frozen --no-dev --no-install-project
