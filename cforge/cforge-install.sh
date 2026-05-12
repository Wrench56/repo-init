#!/bin/sh

# Download the latest or the pinned CForge header from GitHub tags (https://github.com/Wrench56/cforge)

set -eu

TAG="${CFORGE_TAG:-main}"
OUT="${CFORGE_OUTPUT:-cforge.h}"

URL="https://raw.githubusercontent.com/Wrench56/cforge/$TAG/cforge.h"

if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$URL" -o "$OUT"
elif command -v wget >/dev/null 2>&1; then
    wget -q "$URL" -O "$OUT"
elif command -v fetch >/dev/null 2>&1; then
    fetch -q -o "$OUT" "$URL"
else
    echo "Error: Install curl, wget, or fetch" >&2
    exit 1
fi

echo "Downloaded $OUT from $TAG"
