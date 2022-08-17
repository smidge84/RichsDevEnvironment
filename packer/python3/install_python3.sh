#!/usr/bin/env bash

echo "==> PYTHON3 SETUP SCRIPT"

echo "Target Python 3 version = ${PYTHON3_VERSION}"

if [[ ! "${PYTHON3_VERSION}" =~ latest ]]; then
    python3_tag="=${PYTHON3_VERSION}"
fi

# Exit on non-zero exit codes from this point (no more conditioinal statements allowed)
set -e

echo "==> Adding build-dependencies..."
apk --update add --virtual build-dependencies \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    python3-dev${python3_tag}

echo "==> Adding Python runtime..."
apk add --no-cache "python3${python3_tag}" py3-pip
pip install --upgrade pip
pip install wheel
pip install python-keyczar

# Add Python support for Docker 
# TODO: Move this later to be part of the tasks when Docker is installed
echo "==> Installing Docker SDK for Python..." && \
pip install "docker"

echo "==> END PYTHON3 SETUP SCRIPT"
