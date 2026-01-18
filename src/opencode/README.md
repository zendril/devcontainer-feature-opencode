# OpenCode Dev Container Feature

Installs [OpenCode](https://opencode.ai) with persistent configuration and session history.

## Features
- Installs the `opencode` CLI.
- Automatically persists:
    - Authentication (`~/.local/share/opencode/auth.json`)
    - Session history and storage (`~/.local/share/opencode/storage`)
    - Global configuration (`~/.config/opencode`)
    - Prompt history and state (`~/.local/state/opencode`)
    - Cache (`~/.cache/opencode`)

## Usage
Add this feature to your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/zendril/features/opencode:1": {}
  }
}
```

## Options
- `version`: Specify the version of OpenCode to install (default: `latest`).

## Note on Custom Users
Currently, the persistence mounts are hardcoded to `/home/vscode`. If you are using a custom user (e.g., `ubuntu` or a custom username) and need persistence for that user, please open a GitHub issue. We have a planned implementation for dynamic symlinking to support non-standard home directories but have not enabled it yet.
