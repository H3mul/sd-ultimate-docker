#!/usr/bin/env bash
set -eu

echo "Provisioning FluxGym..."

if [ -f ${FLUXGYM_ROOT}/install_complete ]; then 
    echo "install_complete flag file found, skipping FLUXGYM install..."
    exit
fi

[ -d ${FLUXGYM_ROOT} ] || git clone https://github.com/cocktailpeanut/fluxgym ${FLUXGYM_ROOT}

cd ${FLUXGYM_ROOT}

git checkout ${FLUXGYM_VERSION}

[ -d "sd-scripts" ] || git clone -b sd3 https://github.com/kohya-ss/sd-scripts

[ -d venv ] || uv venv --python 3.12 venv

source venv/bin/activate

cd sd-scripts
uv pip install -r requirements.txt
cd ..
uv pip install -r requirements.txt
uv pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu122/torch_stable.html
uv pip install gradeio

uv cache clean
deactivate

touch install_complete