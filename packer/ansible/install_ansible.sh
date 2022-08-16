#!/usr/bin/env bash

echo "==> ANSIBLE SETUP SCRIPT"

echo "Target Ansible version = ${ANSIBLE_VERSION}"
echo "Target Docker SDK for Python version = ${DOCKER_SDK_VERSION}"

if [[ ! "${ANSIBLE_VERSION}" =~ latest ]]; then
    ansible_tag="==${ANSIBLE_VERSION}"
fi

# Exit on non-zero exit codes from this point (no more conditioinal statements allowed)
set -e

# Add popular Python modules which support Ansibile
echo "==> Adding Additional Python Modules..."
python_packages="py3-boto py3-dateutil py3-httplib2 py3-jinja2 py3-paramiko py3-yaml"
python_modules="boto3 python-dateutil httplib2 Jinja2 paramiko pyyaml"
pip install ${python_modules}

echo "==> Adding Ansible..."
pip install "ansible${ansible_tag}"

echo "==> END ANSIBLE SETUP SCRIPT"
