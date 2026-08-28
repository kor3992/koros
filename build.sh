#!/usr/bin/env bash

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$PROJECT_DIR/config/release.conf"

BUILD_DIR="$PROJECT_DIR/build"
ROOTFS="$BUILD_DIR/rootfs"

cleanup() {
    echo ""
    echo "[CLEANUP] Unmounting filesystems..."

    if mountpoint -q "$ROOTFS/dev/pts"; then
        sudo umount "$ROOTFS/dev/pts"
    fi

    if mountpoint -q "$ROOTFS/dev"; then
        sudo umount "$ROOTFS/dev"
    fi

    if mountpoint -q "$ROOTFS/proc"; then
        sudo umount "$ROOTFS/proc"
    fi

    if mountpoint -q "$ROOTFS/sys"; then
        sudo umount "$ROOTFS/sys"
    fi

    if mountpoint -q "$ROOTFS/run"; then
    sudo umount "$ROOTFS/run"
    fi
}

trap cleanup EXIT

echo "================================"
echo "       Building $KOROS_NAME"
echo "       Version: $KOROS_VERSION"
echo "       Ubuntu: $UBUNTU_CODENAME"
echo "================================"

echo ""
echo "[1/5] Cleaning old build..."

cleanup

sudo rm -rf "$BUILD_DIR"

mkdir -p "$ROOTFS"

echo ""
echo "[2/5] Creating Ubuntu base..."

sudo debootstrap \
    --arch="$ARCH" \
    "$UBUNTU_CODENAME" \
    "$ROOTFS" \
    http://archive.ubuntu.com/ubuntu/

echo ""
echo "[3/5] Preparing chroot..."

sudo mount --bind /dev "$ROOTFS/dev"

sudo mkdir -p "$ROOTFS/dev/pts"
sudo mount --bind /dev/pts "$ROOTFS/dev/pts"

sudo mount -t proc proc "$ROOTFS/proc"
sudo mount -t sysfs sys "$ROOTFS/sys"

sudo rm -f "$ROOTFS/etc/resolv.conf"

sudo cp --dereference /etc/resolv.conf \
    "$ROOTFS/etc/resolv.conf"

echo ""
echo "[4/5] Configuring repositories..."

sudo chroot "$ROOTFS" /bin/bash -c '
apt update
apt install -y software-properties-common
add-apt-repository -y universe
apt update
'

echo ""
echo "[5/5] Base build finished!"

echo ""
echo "KorOS root filesystem:"
echo "$ROOTFS"

echo ""
echo "Packages are NOT installed automatically yet."
echo "We will test them first."

