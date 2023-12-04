#!/usr/bin/env bash
set -eu

rm -rf ${KOHYA_ROOT}

# Install Kohya_ss
git clone https://github.com/bmaltais/kohya_ss.git ${KOHYA_ROOT}

cd ${KOHYA_ROOT}

cp /config/kohya_ss/requirements* ./

git checkout ${KOHYA_VERSION}

python3 -m venv --system-site-packages venv
source venv/bin/activate

pip3 install --no-cache-dir torch==2.0.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip3 install --no-cache-dir xformers==0.0.22 \
    bitsandbytes==0.41.1 \
    tensorboard==2.14.1 \
    tensorflow==2.14.0 \
    wheel \
    scipy \
    tensorrt
pip3 install -r requirements.txt
pip3 install .
pip3 cache purge
deactivate
