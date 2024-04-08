FROM debian:latest
ENV DEBIAN_FRONTEND=noninteractive

LABEL description="Secure Boot and dm-verity Demo with QEMU on Debian x64 on ARM Host"

# Install the necessary packages as before
RUN apt-get update && apt-get install -y \
    autoconf \
    autogen \
    bc \
    bison \
    build-essential \
    busybox \
    ccache \
    cpio \
    cryptsetup \
    curl \
    fakeroot \
    findutils \
    flex \
    gettext autopoint \
    git \
    gnu-efi \
    gnupg2\
    gpg \
    grub-efi-amd64-signed \
    grub2 \
    help2man \
    iasl \
    libelf-dev \
    libfdt-dev \
    libglib2.0-dev \
    libgtk-3-dev \
    libncurses5-dev \
    libpixman-1-dev \
    libsdl2-dev \
    libssl-dev \
    libtool \
    libvte-2.91-dev \
    meson \
    nasm \
    ninja-build \
    openssl \
    pkg-config \
    python3 \
    python3-distutils \
    python3-pip \
    python3-setuptools \
    python3-venv \
    qemu-system \
    sbsigntool \
    shtool \
    sudo \
    uuid-dev \
    uuid-runtime \
    wget \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN cpan install File::Slurp
