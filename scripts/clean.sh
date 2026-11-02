#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Cleaning KorOS build files..."

sudo rm -rf -- "$ROOT_DIR/work" "$ROOT_DIR/out"

echo "Build files cleaned."
