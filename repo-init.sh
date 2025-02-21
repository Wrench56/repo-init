#!/bin/sh

# The downloader of repo-setup.sh

# shellcheck disable=SC1090

CONFIG_FILE="./repo.conf"
SETUP_SCRIPT="./repo-setup.sh"
SETUP_SCRIPT_URL="https://raw.githubusercontent.com/Wrench56/repo-init/refs/heads/main/repo-setup.sh"

# Download repo-setup.sh from GitHub
download_file() {
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "$SETUP_SCRIPT" "$SETUP_SCRIPT_URL" && return 0
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$SETUP_SCRIPT" "$SETUP_SCRIPT_URL" && return 0
    fi
    return 1
}


if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
else
    echo "Warning: Configuration file '$CONFIG_FILE' not found. Using defaults."
fi


# Ensure repo-setup.sh exists
if [ ! -f "$SETUP_SCRIPT" ]; then
    if ! download_file; then
        echo "Error: Neither 'curl' nor 'wget' is available."
        echo "Please download manually from:"
        echo "    $SETUP_SCRIPT_URL"
        exit 1
    fi

    echo "'$SETUP_SCRIPT' downloaded successfully."
fi

chmod +x "$SETUP_SCRIPT"

# Run setup script
echo "Running $SETUP_SCRIPT..."
. "$SETUP_SCRIPT"

# Remove setup script after execution
rm -f "$SETUP_SCRIPT"
echo "$SETUP_SCRIPT has been removed after execution."

