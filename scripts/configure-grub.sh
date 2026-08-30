k#!/usr/bin/env bash

set -e


echo "================================"
echo "Configuring KorOS GRUB"
echo "================================"


# ============================================================
# Load KorOS GRUB build configuration
# ============================================================

source /tmp/koros-grub/build.conf


echo ""
echo "GRUB Theme: $KOROS_GRUB_THEME"

echo "GRUB Resolution: $KOROS_GRUB_RESOLUTION"

echo "GRUB Timeout: $KOROS_GRUB_TIMEOUT"


# ============================================================
# Install required GRUB packages
# ============================================================

echo ""
echo "Installing GRUB packages..."

apt update

apt install -y \
    grub-common \
    grub2-common


# ============================================================
# Install the GRUB theme
# ============================================================

echo ""
echo "Installing $KOROS_GRUB_THEME GRUB theme..."

cd /tmp/koros-grub/theme-source

chmod +x install.sh


# Generate the Tela theme directly in /boot/grub/themes
./install.sh \
    -t "$KOROS_GRUB_THEME" \
    -s "$KOROS_GRUB_RESOLUTION" \
    -b


# ============================================================
# Install KorOS GRUB configuration
# ============================================================

echo ""
echo "Installing KorOS GRUB configuration..."

cp \
    /tmp/koros-grub/defaults \
    /etc/default/grub


# ============================================================
# Apply custom timeout
# ============================================================

echo ""
echo "Applying KorOS boot timer..."

sed -i \
    "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=$KOROS_GRUB_TIMEOUT/" \
    /etc/default/grub


echo ""
echo "================================"
echo "KorOS GRUB configuration complete"
echo "================================"

echo ""
echo "Theme: $KOROS_GRUB_THEME"
echo "Resolution: $KOROS_GRUB_RESOLUTION"
echo "Timeout: $KOROS_GRUB_TIMEOUT seconds"
