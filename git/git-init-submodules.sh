#!/bin/sh

# A script to automatically initialize Git submodules

# Check for Git
if ! command -v git >/dev/null 2>&1; then
  echo "Error: Git is not installed." >&2
  exit 1
fi

# Check if submodule is initialized
is_initialized() {
  git submodule status -- "$1" 2>/dev/null | grep -q '^-' && return 1 || return 0
}

# Initialize submodules
all_submodules=$(git config --file .gitmodules --get-regexp 'submodule\..*\.path' | awk '{print $2}')
if [ -n "$GIT_INIT_SUBMODULES" ]; then
  echo "Initializing selected submodules: $GIT_INIT_SUBMODULES"
  for submodule in $GIT_INIT_SUBMODULES; do
    if echo "$all_submodules" | grep -qx "$submodule"; then
      if is_initialized "$submodule"; then
        echo "Submodule '$submodule' already initialized. Skipping."
      else
        echo "Initializing '$submodule'..."
        git submodule update --init "$submodule"
      fi
    else
      echo "Warning: '$submodule' is not a valid submodule path."
    fi
  done
else
  echo "GIT_INIT_SUBMODULES is unset. Initializing all submodules..."
  git submodule update --init --recursive
fi

