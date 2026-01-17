# Plan for opencode Dev Container Feature

We will create a new devcontainer feature for `opencode` in `src/opencode`, modeling it after the `gemini-cli` feature but adapting it for the `opencode` installation method (`curl | bash`) and its specific persistence requirements.

## 1. Structure
We will create the following file structure:
```
src/
  opencode/
    devcontainer-feature.json
    install.sh
```

## 2. Configuration & Persistence (`devcontainer-feature.json`)

**Note on Environment Variables:**
The `opencode` install script (`https://opencode.ai/install`) hardcodes the binary installation path to `$HOME/.opencode/bin` and uses standard XDG logic for finding shell configuration files. It **does not** appear to expose environment variables (like `OPENCODE_HOME`) to override the locations of data, config, or cache directories at install time.
Therefore, to ensure persistence for the user's specific paths, we will use **Docker Volumes** mounted to the standard XDG locations used by `opencode`.

**Mounts:**
We will define the following mounts to persist data across container rebuilds:

1.  **Credentials, History, Logs (`~/.local/share/opencode`):**
    -   Source: `opencode-data`
    -   Target: `/home/vscode/.local/share/opencode` (We will use `$_REMOTE_USER_HOME` in `install.sh` context, but `devcontainer-feature.json` targets are usually absolute or relative to user. We'll stick to standard user home or allow it to be dynamic if the feature supports it, but standard features often assume `/home/vscode` or use `${containerEnv:HOME}` if available, though `devcontainer-feature.json` mounts usually map to a fixed target or rely on the user being `vscode`. Actually, `devcontainer-feature.json` mounts are applied at container creation. We will target the standard paths).
    *Correction:* `devcontainer-feature.json` mount targets are absolute paths inside the container. We typically assume the standard user is `vscode` or `node`, but `opencode` installs to `$HOME`. We will map to `/home/vscode/...` for now as the most common default, but we should be aware of `remoteUser`.

    *Refinement:* The `gemini-cli` example uses `target: "/home/vscode/.gemini"`. We will follow that pattern for now.

    -   **Mount 1:** `opencode-share` -> `/home/vscode/.local/share/opencode`
    -   **Mount 2:** `opencode-config` -> `/home/vscode/.config/opencode`
    -   **Mount 3:** `opencode-cache` -> `/home/vscode/.cache/opencode`

## 3. Installation Logic (`install.sh`)

The script will:
1.  Install necessary system dependencies (e.g., `curl`, `ca-certificates`, `tar` or `unzip` as required by the install script).
2.  Execute the installation command: `curl -fsSL https://opencode.ai/install | bash`.
    -   We can pass `--version` if the user specifies a version in `devcontainer-feature.json` options.
3.  Ensure the `bin` directory (`$HOME/.opencode/bin`) is in the `PATH` (The install script tries to update rc files, but for devcontainers we often want to ensure it's in the global environment or `containerEnv`).
    -   We will likely add `export PATH=$HOME/.opencode/bin:$PATH` to a profile script or rely on `containerEnv` in `devcontainer-feature.json`.
    -   Actually, `devcontainer-feature.json` has `containerEnv`. We should add `PATH` modification there if possible, or just rely on the script. `gemini-cli` example sets `GEMINI_CONFIG_DIR` but relies on the install script/nanolayer for PATH? Nanolayer handles it. Here we might need to manually ensure it.
    -   We will add `PATH: "/home/vscode/.opencode/bin:${PATH}"` to `containerEnv`.

## 4. Execution Plan
1.  Create `src/opencode` directory.
2.  Write `src/opencode/install.sh`.
3.  Write `src/opencode/devcontainer-feature.json`.
4.  Add GitHub Action for automated publication (`.github/workflows/publish-features.yml`).
5.  Test the feature (if possible, or just verify file content).

