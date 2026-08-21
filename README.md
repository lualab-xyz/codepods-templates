# CodePods Templates

A collection of **container templates** for running different **AI command-line (CLI) assistants** accessible from the web browser. These templates are designed to be consumed by [**CodePods**](https://github.com/lualab-xyz/codepods), the orchestrator that deploys each template as a containerized *pod* with an interactive web terminal.

## How it works

Each template packages an AI CLI inside a Docker image based on `ubuntu:24.04`. The `entrypoint` itself only keeps the container alive; services are started independently through the orchestrator's `start_agent` command:

1. `start_agent` launches **[ttyd](https://github.com/tsl0922/ttyd)** on the configured port (`7681` by default).
2. ttyd attaches a persistent **[tmux](https://github.com/tmux/tmux)** session that runs the corresponding CLI in `/workspace`.
3. For agents with a web UI, `start_agent` also starts that second service on its own port.
4. `stop_agent` cleanly stops the previous instance so it can be restarted (`stop_agent` → `start_agent`).
5. `set_provider` configures the BYOK provider in each CLI's native configuration.

## Security

Each template runs the agent as a **non-root** user (`agent`) for better isolation. The container's default user is `agent`; the CLI, ttyd and tmux all run as this user inside `/workspace` (which is owned by `agent`). The agent's home directory is `/home/agent`, where each CLI keeps its native configuration.

System-level provisioning commands (e.g. installing the git proxy into `/usr/local/bin`) still require root and are run by the orchestrator as needed. When adding a new template, keep the `USER agent` directive as the last line of the `Dockerfile` so the runtime runs unprivileged.

## Template structure

```
<template>/
├── manifest.yml        # Metadata: name, description, icons, services and commands
├── Dockerfile          # Base image + CLI installation + ttyd
├── entrypoint.sh       # Container keepalive (tail -f /dev/null)
├── start-agent.sh      # Starts ttyd/tmux (and the web UI if applicable)
├── stop-agent.sh       # Stops the previous start_agent instance
├── set-provider.sh     # Configures the CLI's BYOK provider
├── defaults.env        # Default variables (ports, terminal, model…)
├── files/              # Native CLI configurations
└── *-light.svg|png     # Light-mode icon
└── *-dark.svg|png      # Dark-mode icon
```

### `manifest.yml`

Describes the template for CodePods:

```yaml
display_name: "Copilot"
description: "GitHub Copilot CLI configuration"
workspace_path: "/workspace"
home_path: "/home/agent"          # home directory of the non-root user that runs the agent
user: "agent"                     # non-root user that runs the agent
icon: "copilot-light.svg"
icon_dark: "copilot-dark.svg"
services:
  - "terminal|Copilot CLI|7681"   # <name>|<type>|<port>
commands:
  - set_provider: "/usr/local/bin/set-provider.sh $baseUrl $modelName $apiKey $providerName $providerType"
  - start_agent: "/usr/local/bin/start-agent.sh"
  - stop_agent: "/usr/local/bin/stop-agent.sh"
```

### Ports and variables

Ports can be overridden through environment variables, with *fallback* to the CodePods variables (`CODEPODS_*`):

| Variable | Default | CodePods source | Description |
|----------|---------|-----------------|-------------|
| `TERMINAL_PORT` | `7681` | `CODEPODS_TERMINAL_PORT` | Web terminal port (ttyd) |
| `WEB_PORT` | `4096` / `5494` | `CODEPODS_WEB_PORT` | Web UI port (if applicable) |
| `TERM_FONT_SIZE` | `14` | — | Terminal font size |
| `TERM` | `tmux-256color` | — | Terminal type |
| `LANG` | `en_US.UTF-8` | — | Locale |

## Usage

These templates are not run directly: CodePods discovers them, builds the corresponding image and deploys the pod. See the [CodePods](https://github.com/lualab-xyz/codepods) documentation to learn how to register and launch a template.

To build and test an image manually:

```bash
cd copilot
docker build -t codepods/copilot .
docker run -d --name copilot-test -p 7681:7681 -e CODEPODS_TERMINAL_PORT=7681 codepods/copilot

# Start the services
docker exec copilot-test /usr/local/bin/start-agent.sh
# or, if it was already running, restart:
docker exec copilot-test /usr/local/bin/stop-agent.sh
docker exec copilot-test /usr/local/bin/start-agent.sh

# Open http://localhost:7681 in your browser
```

> ⚠️ The first time the CLI starts inside the container it will require authentication (e.g. `/login`) with the corresponding provider's credentials. Alternatively, `set_provider` lets you inject the BYOK configuration from the orchestrator.

## Terminal tips (ttyd)

The web terminal is powered by [ttyd](https://github.com/tsl0922/ttyd) + [tmux](https://github.com/tmux/tmux). Some shortcuts differ from a native terminal:

- **New line / send message**: press **`Alt` + `Enter`** to insert a new line without sending the message to the CLI.
- **Copy**: hold **`Shift`** while selecting text, then release — the selection is copied to the browser clipboard. (In TUI apps the app captures the mouse, so `Shift` is required to select.)
- **Paste**: press **`Shift`** + `Insert`, or use the browser's paste shortcut (`Ctrl` + `V` / `Cmd` + `V`).
- **`Ctrl` + `C`** is intercepted by the terminal as the interrupt signal (SIGINT), not copy.

## Adding a new template

1. Create a new folder (e.g. `my-cli/`) replicating the structure above.
2. Write a `Dockerfile` that installs the CLI and `ttyd`, and copies `entrypoint.sh`, `start-agent.sh`, `stop-agent.sh` and `set-provider.sh`. End the `Dockerfile` with `USER agent` so the agent runs as a non-root user (see [Security](#security)).
3. `entrypoint.sh` must be a keepalive (`tail -f /dev/null`); the actual startup goes in `start-agent.sh`.
4. Write `start-agent.sh` to launch `ttyd` + `tmux` with the CLI in `/workspace`. If the CLI has a web UI, add a `web` service as in `opencode/`, `kimi/` or `openclaw/`.
5. Add `stop-agent.sh` so the session can be cleanly restarted.
6. Define `manifest.yml`, `defaults.env` and the icons.
7. Register the template in CodePods.

## License

This repository is part of the [CodePods](https://github.com/lualab-xyz/codepods) ecosystem. See the main project for license details.
