#!/usr/bin/env bash
set -eu

# Install Kohya_ss
[ -d ${A1111_ROOT} ] || git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git ${A1111_ROOT}

cd ${A1111_ROOT}

git fetch --tags > /dev/null 2>&1
git checkout ${A1111_VERSION}

if [ -f install_complete ]; then 
    echo "install_complete flag file found, skipping A1111 install..."
    exit
fi

[ -d venv ] || python3 -m venv --system-site-packages venv
source venv/bin/activate

cp /app/config/a1111/{requirements.txt,requirements_versions.txt,install-automatic.py} ./

pip3 install torch==2.0.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip3 install xformers==0.0.22 tensorrt
pip3 install -r requirements_versions.txt

echo "Initial reqs complete, running A1111 install..."
python3 -m install-automatic --skip-torch-cuda-test

echo "Downloading SDXL styles..."
aria2c https://raw.githubusercontent.com/Douleb/SDXL-750-Styles-GPT4-/main/styles.csv -o ./styles.csv

echo "Installing plugins..."
git clone https://github.com/d8ahazard/sd_dreambooth_extension.git extensions/sd_dreambooth_extension
git clone --depth=1 https://github.com/deforum-art/sd-webui-deforum.git extensions/deforum
git clone --depth=1 https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet
git clone --depth=1 https://github.com/ashleykleynhans/a1111-sd-webui-locon.git extensions/a1111-sd-webui-locon
git clone --depth=1 https://github.com/Gourieff/sd-webui-reactor.git extensions/sd-webui-reactor
git clone --depth=1 https://github.com/zanllp/sd-webui-infinite-image-browsing.git extensions/infinite-image-browsing
git clone --depth=1 https://github.com/Bing-su/adetailer.git extensions/adetailer

cd ${A1111_ROOT}/extensions/deforum
pip3 install -r requirements.txt
cd ${A1111_ROOT}/extensions/sd-webui-controlnet
pip3 install -r requirements.txt
cd ${A1111_ROOT}/extensions/sd-webui-reactor
pip3 install -r requirements.txt
pip3 install onnxruntime-gpu
echo "CUDA" > last_device.txt
cd ${A1111_ROOT}/extensions/infinite-image-browsing
pip3 install -r requirements.txt
cd ${A1111_ROOT}/extensions/adetailer
python3 -m install

cd ${A1111_ROOT}/extensions/sd_dreambooth_extension
git checkout main
git reset ${DREAMBOOTH_COMMIT} --hard
cp /app/config/a1111/requirements_dreambooth.txt ./requirements.txt
pip3 install -r requirements.txt

cp /app/config/a1111/{webui-user.sh,config.json,ui-config.json} ./

pip3 cache purge

deactivate
touch install_complete
