#!/usr/bin/env bash
set -euo pipefail

# Dev Container Feature installers run as root. Install the Codex executable
# system-wide, while keeping the remote user's runtime state in the volume-backed
# CODEX_HOME configured by devcontainer-feature.json.
USERNAME="${_REMOTE_USER:-vscode}"
USER_GROUP="$(id -gn "$USERNAME")"
CODEX_STATE_DIR="/var/lib/codex"

install_dependencies() {
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            ca-certificates curl tar
        rm -rf /var/lib/apt/lists/*
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache ca-certificates curl tar
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y ca-certificates curl tar
        dnf clean all
    elif command -v yum >/dev/null 2>&1; then
        yum install -y ca-certificates curl tar
        yum clean all
    elif ! command -v curl >/dev/null 2>&1 || ! command -v tar >/dev/null 2>&1; then
        echo "Codex installation requires curl and tar." >&2
        exit 1
    fi
}

install_dependencies

# Seed a new named volume with private, remote-user-owned state and file-based
# credential storage. Existing volumes retain their contents across rebuilds.
install -d -m 0700 -o "$USERNAME" -g "$USER_GROUP" "$CODEX_STATE_DIR"
printf '%s\n' \
    '# Store Codex credentials in the persistent CODEX_HOME volume.' \
    'cli_auth_credentials_store = "file"' \
    > "$CODEX_STATE_DIR/config.toml"
chown "$USERNAME:$USER_GROUP" "$CODEX_STATE_DIR/config.toml"
chmod 0600 "$CODEX_STATE_DIR/config.toml"

echo "Installing OpenAI Codex ${VERSION:-latest}..."

# Keep installed packages outside the runtime CODEX_HOME volume. Otherwise the
# volume would hide the package that the native installer places under CODEX_HOME.
CODEX_RELEASE="${VERSION:-latest}" \
CODEX_NON_INTERACTIVE=true \
CODEX_INSTALL_DIR=/usr/local/bin \
CODEX_HOME=/usr/local/share/codex \
sh -c 'curl -fsSL https://chatgpt.com/codex/install.sh | sh'

codex --version
