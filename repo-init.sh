#!/bin/sh

# repo-init main script

# shellcheck disable=SC1090,SC2153,SC2154

set -e

CONFIG_FILE="./repo.conf"
DEFAULT_REPO_URL="https://raw.githubusercontent.com/Wrench56/repo-init/main"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
else
    echo "Error: No configuration found!" >&2
    exit 1
fi

# Ensure required config variables are set
: "${TOOLS_DIR:?Error: TOOLS_DIR is not defined in repo.conf}"
: "${TOOLS_LIST:?Error: TOOLS_LIST is not defined in repo.conf}"

# Ensure TOOLS_DIR exists
mkdir -p "$TOOLS_DIR" || {
    echo "Error: Could not create tools directory '$TOOLS_DIR'." >&2
    exit 1
}

# Download files using curl or wget
download_file() {
    url="$1"
    dest="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "$dest" "$url" && return 0
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$dest" "$url" && return 0
    fi

    echo "Error: Neither 'curl' nor 'wget' is available. Cannot download $url." >&2
    return 1
}


echo "Processing tools..."
echo "$TOOLS_LIST" | grep -vE '^\s*#|^\s*$' | while read -r tool; do
    TOOL_SYSTEM=$(echo "$tool" | cut -d '-' -f1)
    TOOL_SCRIPT="$tool.sh"

    # Check if script exists, otherwise download it
    if [ ! -f "$TOOLS_DIR/$TOOL_SCRIPT" ]; then
        TOOL_URL="$DEFAULT_REPO_URL/$TOOL_SYSTEM/$TOOL_SCRIPT"
        echo "Downloading $TOOL_SCRIPT from $TOOL_URL..."

        if ! download_file "$TOOL_URL" "$TOOLS_DIR/$TOOL_SCRIPT"; then
            echo "Error: Failed to download $TOOL_SCRIPT. Skipping..." >&2
            continue
        fi
    fi

    chmod +x "$TOOLS_DIR/$TOOL_SCRIPT"
    echo "Installing $tool..."
    "$TOOLS_DIR/$TOOL_SCRIPT" "$TOOLS_DIR"
    rm -f "$TOOLS_DIR/$TOOL_SCRIPT"
    echo "Removed $TOOL_SCRIPT after execution."
done

echo "Setup complete!"

