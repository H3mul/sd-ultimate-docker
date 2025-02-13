#!/usr/bin/env bash
set -eu

# Install Kohya_ss
[ -d ${KOHYA_ROOT} ] || git clone https://github.com/bmaltais/kohya_ss.git ${KOHYA_ROOT}

cd ${KOHYA_ROOT}

git fetch --tags > /dev/null 2>&1
git checkout ${KOHYA_VERSION}

if [ -f install_complete ]; then 
    echo "install_complete flag file found, skipping Kohya install..."
    exit
fi

cp /app/config/kohya_ss/requirements* ./

[ -d venv ] || python3 -m venv --system-site-packages venv
source venv/bin/activate

uv pip install torch==2.0.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
uv pip install xformers==0.0.22 \
    bitsandbytes==0.41.1 \
    tensorboard==2.14.1 \
    tensorflow==2.14.0 \
    wheel \
    scipy \
    tensorrt
uv pip install -r requirements.txt
uv pip install .
uv cache clean
deactivate
touch install_complete
