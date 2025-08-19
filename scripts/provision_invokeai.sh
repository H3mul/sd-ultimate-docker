#!/usr/bin/env bash
set -eu

[ -d ${INVOKEAI_ROOT} ] || git clone https://github.com/invoke-ai/InvokeAI.git ${INVOKEAI_ROOT}

cd ${INVOKEAI_ROOT}

git fetch --tags > /dev/null 2>&1
git checkout ${INVOKEAI_VERSION}

if [ -f install_complete ]; then 
    echo "install_complete flag file found, skipping InvokeAI install..."
    exit
fi

# Required by InvokeAI:
# requires-python = ">=3.10, <3.13"
# https://github.com/invoke-ai/InvokeAI/blob/aeee22c5a45de6fb5232f115ef411728628ba5bb/pyproject.toml

[ -d venv ] || uv venv --python 3.12 venv

# source venv/bin/activate

uv pip install -v "InvokeAI[xformers]==${INVOKEAI_PYPI_VERSION}"

[ -f invokeai.yaml ] || cp /app/config/invokeai/invokeai.yaml ./invokeai.yaml

uv cache clean
deactivate
touch install_complete