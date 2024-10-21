#!/usr/bin/env bash
set -eu

# Install Kohya_ss
[ -d ${COMFYUI_ROOT} ] || git clone https://github.com/comfyanonymous/ComfyUI ${COMFYUI_ROOT}

cd ${COMFYUI_ROOT}

git fetch --tags > /dev/null 2>&1
git checkout ${COMFYUI_VERSION}

if [ -f install_complete ]; then
    echo "install_complete flag file found, skipping COMFYUI install..."
    exit
fi

[ -d venv ] || python3 -m venv --system-site-packages venv
source venv/bin/activate

uv pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
uv pip install -r requirements.txt

git -C ./custom_nodes clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git
git -C ./custom_nodes clone --depth 1 https://github.com/XLabs-AI/x-flux-comfyui
git -C ./custom_nodes clone --depth 1 https://github.com/Fannovel16/comfyui_controlnet_aux
git -C ./custom_nodes clone --depth 1 https://github.com/rgthree/rgthree-comfy

for dir in $PWD/custom_nodes/*/; do
    if [ -d "$dir" ] && [ -f "$dir/requirements.txt" ]; then
        echo "Installing module requirements: $dir"
        uv pip install -qq -r $dir/requirements.txt
    fi
done

# Link output to input for convenience
rm -r input
ln -s output input

uv cache clean
deactivate
touch install_complete
