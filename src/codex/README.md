# OpenAI Codex Dev Container Feature

Installs the [OpenAI Codex CLI](https://developers.openai.com/codex/cli/)
with OpenAI's native Linux installer and automatically persists local Codex
state across container restarts and rebuilds.

## Persisted state

The feature sets `CODEX_HOME=/var/lib/codex` and mounts the `codex-data` named
volume there. This keeps the complete Codex state directory, including:

- authentication (`auth.json`), with file-based credential storage enabled;
- user configuration (`config.toml`);
- conversation history and resumable sessions;
- other Codex state stored under `CODEX_HOME`.

The named volume is intentionally shared by containers that use this feature so
credentials and history survive rebuilds. Treat it as sensitive data because it
can contain access tokens.

## Usage

Add the feature to your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/zendril/features/codex:1": {}
  }
}
```

After the container starts, run `codex` and sign in. Later container starts and
rebuilds reuse the same authentication and session history automatically.

## Options

- `version`: Codex CLI release to install. Defaults to `latest`.
