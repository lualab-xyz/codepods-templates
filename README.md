# CodePods Templates

A collection of **container templates** for running different **AI command-line (CLI) assistants** accessible from the web browser. These templates are designed to be consumed by [**CodePods**](https://github.com/lualab-xyz/codepods), the orchestrator that deploys each template as a containerized *pod* with an interactive web terminal.

## How it works

Each template packages an AI CLI inside a Docker image that starts from a shared base image (`codepods-ubuntu24`, built from [`ubuntu24/`](ubuntu24) — see [Base image](#base-image)). The `entrypoint` starts the container (ttyd on first start, per `seed-config.sh`) and then only keeps the container alive; services are started independently through the orchestrator's `start_agent` command:

1. `start_agent` launches **[ttyd](https://github.com/tsl0922/ttyd)** on the configured port (`7681` by default).
2. The ttyd session attaches a persistent **[tmux](https://github.com/tmux/tmux)** that runs the corresponding CLI in `/workspace`.
3. For agents with a web UI, `start_agent` also starts that second service on its own port.
4. `stop_agent` cleanly stops the previous instance so it can be restarted (`stop_agent` → `start_agent`).
5. `set_provider` configures the BYOK provider in each CLI's native configuration.

## Security

Each template runs the agent as a **non-root** user (`agent`) for better isolation. The container's default user is `agent`; the CLI, ttyd and tmux all run as this user inside `/workspace` (which is owned by `agent`). The agent's home directory is `/home/agent`, where each CLI keeps its native configuration.

The image is **read-only** for the agent user except for `$HOME`, `/workspace` and `/tmp` — nothing writes to `/opt` or `/usr/local` at runtime. Nothing is baked into `$HOME` at build time (the host maps/mounts that directory), so per-user base configs (`~/.tmux.conf`, and the CLI's native config files) are seeded at container start by `seed-config.sh` from read-only templates under `/opt`. Runtime configuration (ports, BYOK keys, …) is injected by the orchestrator via environment variables (`docker exec --user agent -e VAR=...`), and BYOK settings persisted by `set_provider` are stored under `$HOME/.config/codepods.env`. The git proxy is installed per-user into `$HOME/.local/bin` (prepended to `PATH` in `start-agent.sh`). When installing the proxy, any **real git binary is deleted** — not moved or renamed — so agents can only ever run the proxy; images ship with no git, and the script also tries to remove any git appearing at the system paths (best-effort, it needs root). When adding a new template, keep the `USER agent` directive as the last line of the `Dockerfile` so the runtime runs unprivileged.

## Template structure

```
<template>/
├── manifest.yml        # Metadata: name, description, icons, services, commands, image_base
├── Dockerfile          # FROM shared base image + CLI install + agent-specific files
├── entrypoint.sh       # Runs seed-config.sh + container keepalive (tail -f /dev/null)
├── seed-config.sh      # Seeds per-user base config on first start
├── start-agent.sh      # Starts ttyd/tmux (and the web UI if applicable)
├── stop-agent.sh       # Stops the previous start_agent instance
├── set-provider.sh     # Configures the CLI's BYOK provider (stores config in $HOME)
├── add-mcp-server.sh   # Adds an MCP server (copilot/codex/opencode)
├── remove-mcp-server.sh# Removes an MCP server (copilot/codex/opencode)
├── get-mcps.sh         # Lists configured MCP servers (copilot/codex/opencode)
├── add-skill.sh        # Installs a skill from a zip (URL or path) (copilot/codex/opencode)
├── remove-skill.sh     # Removes a skill by name (copilot/codex/opencode)
├── get-skills.sh       # Lists installed skills (copilot/codex/opencode)
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
image_base:                       # shared base image the Dockerfile starts from
  name: "codepods-ubuntu24:latest"
  repository: "https://github.com/lualab-xyz/codepods-templates.git"
  branch: "main"
  folder: "ubuntu24"
  dockerfile: "Dockerfile"
services:
  - "terminal|Copilot CLI|7681"   # <name>|<type>|<port>
commands:
  - set_provider: "/usr/local/bin/set-provider.sh $baseUrl $modelName $apiKey $providerName $providerType"
  - start_agent: "/usr/local/bin/start-agent.sh"
  - stop_agent: "/usr/local/bin/stop-agent.sh"
```

### Base image

All templates share a common base image built from the `ubuntu24/` folder
(`ubuntu:24.04` + common tooling: Node 22 LTS, tmux, ttyd, the git proxy script
and the generic ttyd UI under `/opt`). Agent templates then only install the
CLI and copy their own scripts:

```dockerfile
# <template>/Dockerfile
FROM codepods-ubuntu24:latest      # FROM <image_base.name>
RUN npm install -g <cli>
...                                # agent-specific scripts
```

CodePods builds the base image first (`docker build -t codepods-ubuntu24:latest ./ubuntu24`), then the agent images. Each `manifest.yml` declares its base with `image_base` (`name`, `repository`, `branch`, `folder`, `dockerfile`), so the base can be built from its repository (checked out at `branch`), and the orchestrator may rewrite the `FROM` line of the agent Dockerfile (which must reference `image_base.name`) to another image chosen at deploy time (e.g. `codepods-ubuntu26:test`), without changing the template sources. To test the stack manually:

```bash
docker build -t codepods-ubuntu24:latest ./ubuntu24
docker build -t codepods/copilot  ./copilot
```

The base image intentionally ships **no agent and no git**: agent CLIs and their scripts live in the agent images, and the git proxy is a self-contained per-runner script copied at build time but which only installs binaries into `$HOME/.local/bin` at runtime (`start-agent.sh` prepends it to `PATH`).

### Ports and variables

Ports can be overridden through environment variables, with *fallback* to the CodePods variables (`CODEPODS_*`). `start-agent.sh` sources `${HOME}/.config/codepods.env` (if present) and pushes the resolved runtime variables into the tmux session environment, so the CLI inherits them without writing any file:

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

# Start the services (as the non-root agent user, with runtime env)
docker exec --user agent -e HOME=/home/agent -e TERMINAL_PORT=7681 copilot-test /usr/local/bin/start-agent.sh
# or, if it was already running, restart:
docker exec --user agent -e HOME=/home/agent -e TERMINAL_PORT=7681 copilot-test /usr/local/bin/stop-agent.sh
docker exec --user agent -e HOME=/home/agent -e TERMINAL_PORT=7681 copilot-test /usr/local/bin/start-agent.sh

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
2. Write a `Dockerfile` starting with `FROM codepods-ubuntu24:latest` that installs the CLI and copies `entrypoint.sh`, `seed-config.sh`, `start-agent.sh`, `stop-agent.sh` and `set-provider.sh` (see [Base image](#base-image)). End the `Dockerfile` with `USER agent` so the agent runs as a non-root user (see [Security](#security)). Add the `image_base` block to `manifest.yml` (copy it from any existing template).
3. `entrypoint.sh` must invoke `seed-config.sh` and then be a keepalive (`tail -f /dev/null`); the actual startup goes in `start-agent.sh`.
4. Write `seed-config.sh` to seed the per-user base configs on first start. Keep any static templates under `/opt` (read-only, not covered by the `$HOME` mount) and copy them to `$HOME` only if they don't exist yet.
5. Write `start-agent.sh` to launch `ttyd` + `tmux` with the CLI in `/workspace`. If the CLI has a web UI, add a `web` service as in `opencode/`, `kimi/` or `openclaw/`.
6. Add `stop-agent.sh` so the session can be cleanly restarted.
7. If the CLI supports MCP servers and/or skills, add `add-mcp-server.sh` / `remove-mcp-server.sh` / `get-mcps.sh` and `add-skill.sh` / `remove-skill.sh` / `get-skills.sh` (see the `copilot/`, `codex/` and `opencode/` templates for reference; `add-skill.sh` takes a `name` and a zip URL/path and extracts it into the CLI's skill discovery folder, and the `get_*` commands let you re-sync state with the agent).
8. Define `manifest.yml` and the icons.
9. Register the template in CodePods.

## License

This repository is part of the [CodePods](https://github.com/lualab-xyz/codepods) ecosystem. See the main project for license details.
