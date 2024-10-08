# Stage 1: Base
FROM python:3.12

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/London \
    PYTHONUNBUFFERED=1 \
    SHELL=/bin/bash

# Create workspace working directory
WORKDIR /

# Install Ubuntu packages
RUN apt update && \
    apt -y upgrade && \
    apt install -y --no-install-recommends \
        rclone \
        build-essential \
        software-properties-common \
        nodejs \
        npm \
        parallel \
        aria2 \
        bash \
        dos2unix \
        git \
        git-lfs \
        ncdu \
        net-tools \
        inetutils-ping \
        openssh-server \
        libglib2.0-0 \
        libsm6 \
        libgl1 \
        libxrender1 \
        libxext6 \
        ffmpeg \
        wget \
        curl \
        pslist \
        psmisc \
        rsync \
        vim \
        zip \
        unzip \
        p7zip-full \
        htop \
        pkg-config \
        plocate \
        libcairo2-dev \
        libgoogle-perftools4 \
        libtcmalloc-minimal4 \
        apt-transport-https \
        ca-certificates && \
    update-ca-certificates && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# ADD SDXL styles.csv
ADD https://raw.githubusercontent.com/Douleb/SDXL-750-Styles-GPT4-/main/styles.csv /config/styles.csv

# Install VS Server
RUN curl -fsSL https://code-server.dev/install.sh | sh && \
    code-server --install-extension enkia.tokyo-night \
        --install-extension ms-python.python

COPY /vs-server/settings.json /vs-server/settings.json 

# Install runpodctl
RUN wget https://github.com/runpod/runpodctl/releases/download/v1.10.0/runpodctl-linux-amd -O runpodctl && \
    chmod a+x runpodctl && \
    mv runpodctl /usr/local/bin

# Install speedtest CLI
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt install speedtest

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*
RUN mkdir -p /app/{pid,config,scripts}

WORKDIR /

# Copy the scripts
COPY --chmod=755 scripts/* /app/scripts/
COPY model-download-aria2.txt /app/config/

COPY invokeai/invokeai.yaml /app/config/invokeai/invokeai.yaml
COPY a1111/* /app/config/a1111/
COPY kohya_ss/* /app/config/kohya_ss/

ENV PATH=${PATH}:/app/scripts

ENV INSTALL_ROOT=/workspace/apps

ENV ENABLE_KOHYA=false
ENV KOHYA_VERSION=v24.1.6
ENV KOHYA_ROOT="${INSTALL_ROOT}/kohya_ss"
ENV KOHYA_PORT=3000

ENV ENABLE_INVOKEAI=false
ENV INVOKEAI_VERSION=v4.2.9rc1
ENV INVOKEAI_ROOT="${INSTALL_ROOT}/invokeai"
ENV INVOKEAI_PORT=9090

ENV ENABLE_A1111=false
ENV A1111_VERSION=v1.10.0
ENV DREAMBOOTH_COMMIT=1.1.0
ENV A1111_ROOT="${INSTALL_ROOT}/a1111"
ENV A1111_PORT=3000

ENV ENABLE_COMFYUI=false
ENV COMFYUI_VERSION=v0.1.3
ENV COMFYUI_ROOT="${INSTALL_ROOT}/comfyui"
ENV COMFYUI_PORT=8188

ENV DISABLE_MODEL_DOWNLOAD=false
ENV SHUTDOWN_AFTER_PROVISION=false
ENV SHUTDOWN_AFTER_TRAINING=false
ENV DISABLE_AUTOLAUNCH=false
ENV PUSHBULLET_API_TOKEN=""
ENV NOTIFY_ON_TRAINING_END=false

# Slows down bootup but save space (quite a bit of space, ~20Gb usually)
ENV CLEAR_CACHE_ON_SHUTDOWN=true

# Matches most kohya training scripts,
# eg sdxl_train_network.py, sdxl_train.py, train_network.py, etc
ENV TRAINING_PID_PATTERN="train.*\.py"

ENV VS_CODE_PORT=3000

VOLUME [ "/workspace" ]
EXPOSE ${A1111_PORT} ${KOHYA_PORT} ${VS_CODE_PORT} ${INVOKEAI_PORT} ${COMFYUI_PORT}

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/app/scripts/start.sh" ]