#!/usr/bin/env bash

set -e

echo "================================"
echo "Configuring KorOS Live System"
echo "================================"


# ============================================================
# Hostname
# ============================================================

echo "Setting hostname..."

echo "koros" > /etc/hostname

hostnamectl set-hostname koros 2>/dev/null || true


# Configure local hostname resolution

cat > /etc/hosts <<'EOF'
127.0.0.1 localhost
127.0.1.1 koros

::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF


# ============================================================
# Disable graphical boot
# ============================================================

echo "Configuring text-only boot..."

systemctl set-default multi-user.target


# ============================================================
# Disable display managers
# ============================================================

echo "Disabling graphical display managers..."

systemctl disable gdm3 2>/dev/null || true
systemctl disable gdm 2>/dev/null || true
systemctl disable lightdm 2>/dev/null || true
systemctl disable sddm 2>/dev/null || true


# ============================================================
# Create KorOS live user
# ============================================================

echo "Creating KorOS live user..."

if id koros >/dev/null 2>&1; then

    userdel -r koros 2>/dev/null || true

fi


useradd \
    -m \
    -s /usr/bin/fish \
    -G sudo \
    koros


# ============================================================
# Passwordless sudo
# ============================================================

echo "Configuring live sudo..."

cat > /etc/sudoers.d/koros-live <<'EOF'
koros ALL=(ALL) NOPASSWD: ALL
EOF

chmod 440 /etc/sudoers.d/koros-live


# ============================================================
# Automatic login on TTY1
# ============================================================

echo "Configuring automatic login..."

mkdir -p \
    /etc/systemd/system/getty@tty1.service.d


cat > \
    /etc/systemd/system/getty@tty1.service.d/autologin.conf \
    <<'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin koros --noclear %I $TERM
Type=idle
EOF


# ============================================================
# Fish welcome message
# ============================================================

echo "Configuring KorOS welcome message..."

mkdir -p /etc/fish

cat > /etc/fish/config.fish <<'EOF'
if status is-interactive
    clear

    echo ""
    echo "Welcome to KorOS"
    echo 'To install, please run "korinstall"'
    echo ""

    fastfetch
    echo ""
end
EOF


# ============================================================
# Live fstab
# ============================================================

echo "Configuring live filesystem..."

cat > /etc/fstab <<'EOF'
# KorOS Live System
EOF


echo ""
echo "================================"
echo "KorOS Live System configured!"
echo "================================"
