#!/bin/sh

# repo-init main script

# shellcheck disable=SC1090,SC2153,SC2154

CONFIG_FILE="./repo.conf"
DEFAULT_REPO_URL="https://raw.githubusercontent.com/Wrench56/repo-init/main"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
else
    echo "No configuration found!"
    exit 1
fi

# Ensure TOOLS_DIR exists
mkdir -p "$TOOLS_DIR" || {
    echo "Error: Could not create tools directory '$TOOLS_DIR'."
    exit 1
}

# Download files using curl or wget
download_file() {
    URL="$1"
    DEST="$2"

    echo "Attempting to download $URL..."

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "$DEST" "$URL" && return 0
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$DEST" "$URL" && return 0
    fi

    echo "Error: Neither 'curl' nor 'wget' is available. Cannot download $URL."
    return 1
}

FILTERED_TOOLS_LIST=$(echo "$TOOLS_LIST" | grep -vE '^\s*#|^\s*$')
for tool in $FILTERED_TOOLS_LIST; do
    TOOL_DIR=$(echo "$tool" | cut -d '-' -f1)
    TOOL_SCRIPT="$TOOL_DIR/$tool.sh"

    # Check if script exists, otherwise download it
    if [ ! -f "$TOOL_SCRIPT" ]; then
        TOOL_URL="$DEFAULT_REPO_URL/$TOOL_SCRIPT"
        echo "Downloading $TOOL_SCRIPT from $TOOL_URL..."
        
        if ! download_file "$TOOL_URL" "$TOOL_SCRIPT"; then
            echo "Error: Failed to download $TOOL_SCRIPT. Skipping..."
            continue
        fi
    fi

    chmod +x "$TOOL_SCRIPT"
    echo "Installing $tool from $TOOL_SCRIPT..."
    "$TOOL_SCRIPT" "$TOOLS_DIR"
    rm -f "$TOOL_SCRIPT"
    echo "Removed $TOOL_SCRIPT after execution."
done

echo "Setup complete!"

