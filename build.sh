#!/usr/bin/env bash

set -e

# ============================================================
# KorOS Build System
# ============================================================

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$PROJECT_DIR/config/release.conf"

BUILD_DIR="$PROJECT_DIR/build"
ROOTFS="$BUILD_DIR/rootfs"

PACKAGES_DIR="$PROJECT_DIR/packages"

GRUB_SOURCE_DIR="$PROJECT_DIR/boot/grub/source"
GRUB_CONFIG_DIR="$PROJECT_DIR/configs/grub"


# ============================================================
# Cleanup
# ============================================================

cleanup() {

    echo ""
    echo "[CLEANUP] Unmounting filesystems..."

    sudo umount "$ROOTFS/dev/pts" 2>/dev/null || true
    sudo umount "$ROOTFS/dev" 2>/dev/null || true
    sudo umount "$ROOTFS/proc" 2>/dev/null || true
    sudo umount "$ROOTFS/sys" 2>/dev/null || true

}

trap cleanup EXIT


# ============================================================
# Build information
# ============================================================

echo "================================"
echo "       Building $KOROS_NAME"
echo "       Version: $KOROS_VERSION"
echo "       Ubuntu Base: $UBUNTU_CODENAME"
echo "       Architecture: $ARCH"
echo "================================"


# ============================================================
# Step 1 - Clean
# ============================================================

echo ""
echo "[1/12] Cleaning old build..."

cleanup

sudo rm -rf "$BUILD_DIR"

mkdir -p "$ROOTFS"


# ============================================================
# Step 2 - Create root filesystem
# ============================================================

echo ""
echo "[2/12] Creating base system..."

sudo debootstrap \
    --arch="$ARCH" \
    "$UBUNTU_CODENAME" \
    "$ROOTFS" \
    http://archive.ubuntu.com/ubuntu/


# ============================================================
# Step 3 - Prepare chroot
# ============================================================

echo ""
echo "[3/12] Preparing chroot..."

sudo mount --bind /dev \
    "$ROOTFS/dev"

sudo mkdir -p \
    "$ROOTFS/dev/pts"

sudo mount --bind /dev/pts \
    "$ROOTFS/dev/pts"

sudo mount -t proc proc \
    "$ROOTFS/proc"

sudo mount -t sysfs sys \
    "$ROOTFS/sys"


# ============================================================
# Step 4 - DNS
# ============================================================

echo ""
echo "[4/12] Configuring DNS..."

sudo rm -f \
    "$ROOTFS/etc/resolv.conf"

sudo cp -L \
    /etc/resolv.conf \
    "$ROOTFS/etc/resolv.conf"


# ============================================================
# Step 5 - Repositories
# ============================================================

echo ""
echo "[5/12] Configuring repositories..."

sudo chroot "$ROOTFS" \
    /bin/bash -c '

set -e

apt update

apt install -y \
    software-properties-common

add-apt-repository -y universe

apt update
'


# ============================================================
# Step 6 - Packages
# ============================================================

echo ""
echo "[6/12] Installing KorOS packages..."

if [ -d "$PACKAGES_DIR" ]; then

    sudo mkdir -p \
        "$ROOTFS/tmp/koros-packages"

    sudo cp -a \
        "$PACKAGES_DIR/." \
        "$ROOTFS/tmp/koros-packages/"

    sudo chroot "$ROOTFS" \
        /bin/bash -c '

set -e

for package_file in /tmp/koros-packages/*.txt; do

    [ -e "$package_file" ] || continue

    echo ""
    echo "Installing package list:"
    echo "$(basename "$package_file")"

    while IFS= read -r package || [ -n "$package" ]; do

        package="$(echo "$package" | xargs)"

        [ -z "$package" ] && continue

        case "$package" in
            \#*)
                continue
                ;;
        esac

        apt install -y "$package"

    done < "$package_file"

done
'

    sudo rm -rf \
        "$ROOTFS/tmp/koros-packages"

fi


# ============================================================
# Step 7 - Fish
# ============================================================

echo ""
echo "[7/12] Configuring Fish..."

sudo chroot "$ROOTFS" \
    /bin/bash -c '

set -e

FISH_PATH="$(command -v fish)"

grep -qx "$FISH_PATH" /etc/shells || \
    echo "$FISH_PATH" >> /etc/shells

if grep -q "^SHELL=" /etc/default/useradd; then

    sed -i \
        "s|^SHELL=.*|SHELL=$FISH_PATH|" \
        /etc/default/useradd

else

    echo "SHELL=$FISH_PATH" \
        >> /etc/default/useradd

fi
'


# ============================================================
# Step 8 - Alacritty
# ============================================================

echo ""
echo "[8/12] Configuring Alacritty..."

sudo chroot "$ROOTFS" \
    /bin/bash -c '

set -e

update-alternatives \
    --install \
    /usr/bin/x-terminal-emulator \
    x-terminal-emulator \
    /usr/bin/alacritty \
    100

update-alternatives \
    --set \
    x-terminal-emulator \
    /usr/bin/alacritty
'


# ============================================================
# Step 9 - Branding
# ============================================================

echo ""
echo "[9/12] Applying KorOS branding..."

sudo install -m 755 \
    "$PROJECT_DIR/scripts/configure-branding.sh" \
    "$ROOTFS/tmp/configure-branding.sh"

sudo chroot "$ROOTFS" \
    /bin/bash \
    /tmp/configure-branding.sh

sudo rm -f \
    "$ROOTFS/tmp/configure-branding.sh"


# ============================================================
# Step 10 - GRUB
# ============================================================

echo ""
echo "[10/12] Configuring KorOS GRUB..."

if [ ! -d "$GRUB_SOURCE_DIR" ]; then
    echo "ERROR: GRUB theme source missing."
    exit 1
fi

if [ ! -f "$GRUB_CONFIG_DIR/defaults" ]; then
    echo "ERROR: GRUB defaults missing."
    exit 1
fi

sudo mkdir -p \
    "$ROOTFS/tmp/koros-grub"

sudo cp -a \
    "$GRUB_SOURCE_DIR" \
    "$ROOTFS/tmp/koros-grub/theme-source"

sudo cp \
    "$GRUB_CONFIG_DIR/defaults" \
    "$ROOTFS/tmp/koros-grub/defaults"

sudo tee \
    "$ROOTFS/tmp/koros-grub/build.conf" \
    > /dev/null <<EOF
KOROS_GRUB_THEME="${GRUB_THEME:-Tela}"
KOROS_GRUB_RESOLUTION="${GRUB_THEME_RESOLUTION:-1080p}"
KOROS_GRUB_TIMEOUT="${GRUB_TIMEOUT:-5}"
EOF

sudo install -m 755 \
    "$PROJECT_DIR/scripts/configure-grub.sh" \
    "$ROOTFS/tmp/configure-grub.sh"

sudo chroot "$ROOTFS" \
    /bin/bash \
    /tmp/configure-grub.sh

sudo rm -rf \
    "$ROOTFS/tmp/koros-grub"

sudo rm -f \
    "$ROOTFS/tmp/configure-grub.sh"


# ============================================================
# Step 11 - Default user configuration
# ============================================================

echo ""
echo "[11/12] Installing default user configuration..."

sudo mkdir -p \
    "$ROOTFS/etc/skel"

if [ -d "$PROJECT_DIR/configs/skel" ]; then

    sudo cp -a \
        "$PROJECT_DIR/configs/skel/." \
        "$ROOTFS/etc/skel/"

else

    echo "WARNING: configs/skel does not exist."

fi


# ============================================================
# Step 12 - Live environment
# ============================================================

echo ""
echo "[12/12] Configuring KorOS Live System..."

if [ ! -f "$PROJECT_DIR/scripts/configure-live.sh" ]; then

    echo "ERROR: configure-live.sh not found!"
    exit 1

fi

sudo install -m 755 \
    "$PROJECT_DIR/scripts/configure-live.sh" \
    "$ROOTFS/tmp/configure-live.sh"

sudo chroot "$ROOTFS" \
    /bin/bash \
    /tmp/configure-live.sh

sudo rm -f \
    "$ROOTFS/tmp/configure-live.sh"


# ============================================================
# Verify Live configuration
# ============================================================

echo ""
echo "Verifying Live System..."

sudo test -f \
    "$ROOTFS/etc/systemd/system/getty@tty1.service.d/autologin.conf"

sudo chroot "$ROOTFS" \
    id koros

echo ""
echo "================================"
echo "KorOS build completed successfully!"
echo "================================"

echo ""
echo "Live system:"
echo "  ✓ Text mode boot"
echo "  ✓ Graphical login disabled"
echo "  ✓ Automatic login as koros"
echo "  ✓ Fish shell"
echo "  ✓ koros user created"
echo ""
echo "Root filesystem:"
echo "$ROOTFS"
