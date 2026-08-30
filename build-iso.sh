#!/usr/bin/env bash

set -e

# ============================================================
# KorOS ISO Builder
# ============================================================

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$PROJECT_DIR/config/release.conf"

BUILD_DIR="$PROJECT_DIR/build"
ROOTFS="$BUILD_DIR/rootfs"

ISO_DIR="$BUILD_DIR/iso"
OUTPUT_DIR="$PROJECT_DIR/output"

ISO_NAME="${KOROS_NAME}-${KOROS_VERSION}-${ARCH}.iso"


echo "================================"
echo "Building KorOS ISO"
echo "================================"

echo "Name: $ISO_NAME"
echo ""


# ============================================================
# Checks
# ============================================================

[ -d "$ROOTFS" ] || {
    echo "ERROR: Root filesystem not found."
    exit 1
}

[ -f "$PROJECT_DIR/configs/iso/grub.cfg" ] || {
    echo "ERROR: ISO GRUB configuration missing."
    exit 1
}


# ============================================================
# Step 1 - Clean
# ============================================================

echo "[1/7] Cleaning..."

sudo rm -rf \
    "$ISO_DIR"

sudo rm -f \
    "$OUTPUT_DIR/$ISO_NAME"

mkdir -p \
    "$ISO_DIR/casper"

mkdir -p \
    "$ISO_DIR/boot/grub"

mkdir -p \
    "$OUTPUT_DIR"


# ============================================================
# Step 2 - Kernel
# ============================================================

echo "[2/7] Copying kernel..."

KERNEL="$(sudo find "$ROOTFS/boot" \
    -maxdepth 1 \
    -type f \
    -name 'vmlinuz-*' \
    | sort -V \
    | tail -n 1)"

[ -n "$KERNEL" ] || {
    echo "ERROR: Kernel not found."
    exit 1
}

sudo cp \
    "$KERNEL" \
    "$ISO_DIR/casper/vmlinuz"


# ============================================================
# Step 3 - Initrd
# ============================================================

echo "[3/7] Copying initrd..."

INITRD="$(sudo find "$ROOTFS/boot" \
    -maxdepth 1 \
    -type f \
    -name 'initrd.img-*' \
    | sort -V \
    | tail -n 1)"

[ -n "$INITRD" ] || {
    echo "ERROR: Initrd not found."
    exit 1
}

sudo cp \
    "$INITRD" \
    "$ISO_DIR/casper/initrd"


# ============================================================
# Step 4 - SquashFS
# ============================================================

echo "[4/7] Creating SquashFS..."

sudo mksquashfs \
    "$ROOTFS" \
    "$ISO_DIR/casper/filesystem.squashfs" \
    -e boot \
    -noappend


# ============================================================
# Step 5 - GRUB
# ============================================================

echo "[5/7] Installing ISO GRUB configuration..."

sudo cp \
    "$PROJECT_DIR/configs/iso/grub.cfg" \
    "$ISO_DIR/boot/grub/grub.cfg"


# ============================================================
# Step 6 - Permissions
# ============================================================

echo "[6/7] Fixing permissions..."

sudo chmod -R a+rX \
    "$ISO_DIR"

sudo chown -R \
    "$USER:$USER" \
    "$ISO_DIR"


# ============================================================
# Step 7 - ISO
# ============================================================

echo "[7/7] Creating ISO..."

sudo grub-mkrescue \
    -o "$OUTPUT_DIR/$ISO_NAME" \
    "$ISO_DIR"

sudo chown \
    "$USER:$USER" \
    "$OUTPUT_DIR/$ISO_NAME"


echo ""
echo "================================"
echo "KorOS ISO created successfully!"
echo "================================"

echo ""
echo "$OUTPUT_DIR/$ISO_NAME"

ls -lh \
    "$OUTPUT_DIR/$ISO_NAME"
