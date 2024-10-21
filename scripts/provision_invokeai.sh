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

[ -d venv ] || python3 -m venv --system-site-packages venv

source venv/bin/activate

uv pip install -v "InvokeAI[xformers]==${INVOKEAI_PIPY_VERSION}"

[ -f invokeai.yaml ] || cp /app/config/invokeai/invokeai.yaml ./invokeai.yaml

uv cache clean
deactivate
touch install_complete