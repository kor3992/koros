#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE_DIR="$ROOT_DIR/configs/archiso"
WORK_DIR="$ROOT_DIR/work"
OUTPUT_DIR="$ROOT_DIR/out"

if [[ ! -d "$PROFILE_DIR" ]]; then
    echo "Error: Archiso profile not found: $PROFILE_DIR"
    exit 1
fi

if ! command -v mkarchiso >/dev/null 2>&1; then
    echo "Error: mkarchiso is not installed."
    exit 1
fi

mkdir -p "$WORK_DIR" "$OUTPUT_DIR"

echo "Building KorOS ISO..."

sudo mkarchiso \
    -v \
    -w "$WORK_DIR" \
    -o "$OUTPUT_DIR" \
    "$PROFILE_DIR"

echo "KorOS ISO build completed."
