#!/usr/bin/env bash

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_FILE="$PROJECT_DIR/packages/install.txt"

echo "Installing KorOS packages..."

apt update

while IFS= read -r package; do

    # Leere Zeilen ignorieren
    [[ -z "$package" ]] && continue

    # Kommentarzeilen ignorieren
    [[ "$package" == \#* ]] && continue

    echo "Installing: $package"

    apt install -y "$package"

done < "$PACKAGE_FILE"

echo "Package installation finished."
