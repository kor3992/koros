#!/usr/bin/env bash
set -euo pipefail

echo "Preparing KorOS build environment..."

sudo pacman -Syu --needed \
    archiso \
    git \
    base-devel \
    qemu-desktop \
    edk2-ovmf \
    squashfs-tools \
    dosfstools \
    mtools \
    nano

echo
echo "KorOS build environment is ready."
