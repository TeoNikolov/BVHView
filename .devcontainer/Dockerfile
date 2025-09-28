# Start from a minimal base
FROM debian:bookworm-slim

# Core dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    libgl-dev \
    xorg-dev \
    git \
    cmake \
    mingw-w64 \
    ffmpeg \
    sudo

# Create a non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
ENV HOME=/home/$USERNAME
USER $USERNAME
WORKDIR /workspaces

# Clone raylib
RUN git clone --depth 1 --branch master https://github.com/raysan5/raylib.git $HOME/raylib/raylib \
    && cd $HOME/raylib/raylib \
    && git fetch --depth 1 origin add4da8fb32fdd422201fb0b57329235c99f831d \
    && git checkout add4da8fb32fdd422201fb0b57329235c99f831d \
    && git clone --depth 1 --branch master https://github.com/raysan5/raygui.git $HOME/raylib/raygui \
    && cd $HOME/raylib/raygui \
    && git fetch --depth 1 origin 1536ae35c7b42d863135f4181fd2a225e531f68b \
    && git checkout 1536ae35c7b42d863135f4181fd2a225e531f68b

# Setup EMSDK (web builds)
RUN git clone --branch main https://github.com/emscripten-core/emsdk.git $HOME/emsdk \
    && cd $HOME/emsdk \
    && git checkout tags/4.0.15 \
    && ./emsdk install latest \
    && ./emsdk activate latest

# Modify file contents
RUN sed -i "s|EMSDK_PATH\s*?=.*|EMSDK_PATH         ?= $HOME/emsdk|g" $HOME/raylib/raylib/src/Makefile \
    && grep -q "export PATH\s*:= \$(EMSDK_PATH);\$(EMSCRIPTEN_PATH);\$(CLANG_PATH);\$(NODE_PATH);\$(PYTHON_PATH);C:/raylib/MinGW/bin;\$(PATH)" $HOME/raylib/raylib/src/Makefile \
    && sed -i 's|.*export PATH.*|PATH = $(shell printenv PATH):$(EMSDK_PATH):$(EMSCRIPTEN_PATH):$(CLANG_PATH):$(NODE_PATH):$(PYTHON_PATH)|' $HOME/raylib/raylib/src/Makefile

# Build raylib
RUN bash -c "source $HOME/emsdk/emsdk_env.sh && \
    cd $HOME/raylib/raylib/src && \
    # Linux static build
    make -B PLATFORM=PLATFORM_DESKTOP RAYLIB_LIBTYPE=STATIC CC=gcc PLATFORM_OS=LINUX && \
    mkdir -p $HOME/raylib/lib/linux && cp libraylib.a $HOME/raylib/lib/linux/ && \
    # Windows static build
    make clean && \
    make -B PLATFORM=PLATFORM_DESKTOP RAYLIB_LIBTYPE=STATIC CC=x86_64-w64-mingw32-gcc PLATFORM_OS=WINDOWS && \
    mkdir -p $HOME/raylib/lib/windows && cp libraylib.a $HOME/raylib/lib/windows/ && \
    # Web static build
    make clean && \
    make -B PLATFORM=PLATFORM_WEB RAYLIB_LIBTYPE=STATIC && \
    mkdir -p $HOME/raylib/lib/web && cp libraylib.web.a $HOME/raylib/lib/web/"
