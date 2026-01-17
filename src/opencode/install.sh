#!/usr/bin/env bash
set -e

# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI:
# _REMOTE_USER: The user name of the non-root user for the Dev Container.
# _REMOTE_USER_HOME: The home directory of the non-root user for the Dev Container.

USERNAME="${_REMOTE_USER:-vscode}"
USER_HOME="${_REMOTE_USER_HOME:-/home/$USERNAME}"

echo "Installing dependencies..."
apt-get update && apt-get install -y curl ca-certificates tar unzip

echo "Installing OpenCode for user ${USERNAME}..."

# Determine version argument
VERSION_ARG=""
if [ -n "${VERSION}" ] && [ "${VERSION}" != "latest" ]; then
    VERSION_ARG="--version ${VERSION}"
fi

# Run the installer as the target user
# We use 'bash -s' to pass arguments to the piped script
su - "$USERNAME" -c "curl -fsSL https://opencode.ai/install | bash -s -- ${VERSION_ARG}"

# Pre-create directories for persistence mounts to ensure correct permissions
# (Docker might create them as root otherwise when mounting volumes)
mkdir -p "$USER_HOME/.local/share/opencode"
mkdir -p "$USER_HOME/.config/opencode"
mkdir -p "$USER_HOME/.cache/opencode"

chown -R "$USERNAME:$USERNAME" "$USER_HOME/.local/share/opencode"
chown -R "$USERNAME:$USERNAME" "$USER_HOME/.config/opencode"
chown -R "$USERNAME:$USERNAME" "$USER_HOME/.cache/opencode"

echo "OpenCode installed successfully."

# Cleanup
rm -rf /var/lib/apt/lists/*
