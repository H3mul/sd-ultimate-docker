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

pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
pip3 install -r requirements.txt
pip3 cache purge

# git -C ./custom_nodes clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git
# git -C ./custom_nodes clone --depth 1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
# git -C ./custom_nodes clone --depth 1 https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git
# git -C ./custom_nodes clone --depth 1 https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolvet
# git -C ./custom_nodes clone --depth 1 https://github.com/Fannovel16/comfyui_controlnet_aux.git
# git -C ./custom_nodes clone --depth 1 https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git
# git -C ./custom_nodes clone --depth 1 https://github.com/jags111/efficiency-nodes-comfyui.git
# git -C ./custom_nodes clone --depth 1 https://github.com/kijai/ComfyUI-KJNodes.git
# git -C ./custom_nodes clone --depth 1 https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
# git -C ./custom_nodes clone --depth 1 https://github.com/cubiq/ComfyUI_essentials.git
# git -C ./custom_nodes clone --depth 1 https://github.com/FizzleDorf/ComfyUI_FizzNodes.git

# for dir in $PWD/custom_nodes/*/; do
#  if [ -d "$dir" ]; then
#   echo "Entering module: $dir"
#   (cd "$dir" && pip install -qq -r requirements.txt)
#  fi
# done

deactivate
touch install_complete
