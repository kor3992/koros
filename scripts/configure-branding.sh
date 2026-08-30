#!/usr/bin/env bash

set -e

KOROS_NAME="KorOS"
KOROS_VERSION="0.1"

echo "Configuring KorOS branding..."

cat > /etc/os-release << EOF
NAME="$KOROS_NAME"
PRETTY_NAME="$KOROS_NAME $KOROS_VERSION"
ID=koros
VERSION_ID="$KOROS_VERSION"
VERSION="$KOROS_VERSION"
EOF

cat > /etc/issue << EOF
Welcome to KorOS $KOROS_VERSION

EOF

cat > /etc/issue.net << EOF
KorOS $KOROS_VERSION
EOF

cat > /etc/koros-release << EOF
KorOS $KOROS_VERSION
EOF

echo "KorOS branding configured."
