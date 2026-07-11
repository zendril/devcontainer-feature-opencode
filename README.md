# Dev Container Features

This repository publishes a collection of Dev Container Features for AI coding
agents.

## Available features

| Feature | Description |
| --- | --- |
| [`codex`](src/codex/README.md) | Installs OpenAI Codex and persists authentication, configuration, and session history. |
| [`opencode`](src/opencode/README.md) | Installs OpenCode with persistent configuration and session history. |

Each feature is independently versioned and published from its directory under
`src/`.

## Usage

Add one or both features to your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/zendril/features/codex:1": {},
    "ghcr.io/zendril/features/opencode:1": {}
  }
}
```
