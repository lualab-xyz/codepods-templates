# CodePods Templates — diseño

## Qué es
Templates de agentes IA CLI para CodePods (claude, codex, copilot, gemini, kimi, openclaw, opencode). Cada template = imagen Docker + scripts de arranque/config + manifest.yml. La plataforma CodePods build-a y despliega pods con terminal web (ttyd+tmux).

## Arquitectura (feature base-image)
- **Imagen base común** `ubuntu24/`: `ubuntu:24.04` + Node 22 LTS (nodesource, sin git) + tmux + ttyd + `/opt/tmux/.tmux.conf` + `/opt/ttyd/index.html` genérico + `set-git-proxy.sh` + user `agent` (HOME `/home/agent`, PATH incluye `~/.local/bin`, WORKDIR `/workspace`). Sin agente, sin ENTRYPOINT, sin git, sin labels.
- **Imágenes de agente**: `FROM codepods-ubuntu24:latest` + RUN del instalador del CLI + COPY de sus scripts + `COPY files/ttyd/index.html /opt/ttyd/index.html` (override del branding) + chmod + USER agent + ENTRYPOINT propio.
- **`manifest.yml`**: añade bloque `image_base { name, repository, branch, folder, dockerfile }` apuntando a `ubuntu24/Dockerfile` (branch `main` por defecto). La plataforma build-a la base primero y PUEDE reescribir la línea FROM al vuelo para usar otra imagen elegida en despliegue (p. ej. `codepods-ubuntu26:test`).
- **Labels de imagen** (`io.codepods.*`): los genera la plataforma en build; NO están en los Dockerfiles del repo.

## Runtime (invariantes críticos)
- La plataforma **monta un volumen sobre $HOME en runtime** que sustituye todo el contenido de build en HOME. Ficheros/binarios necesarios en runtime (p. ej. binario `kimi`) deben copiarse a paths de sistema (`/usr/local/bin`).
- Configs por usuario las siembra `seed-config.sh` desde `/opt` (solo si no existen). BYOK runtime via env (`docker exec -e`) y `$HOME/.config/codepods.env` (escrito por set_provider).
- Proxy git: `set-git-proxy.sh` se copia a `/usr/local/bin` en build; instala el binario per-user en `$HOME/.local/bin` (que `start-agent.sh` antepone al PATH). Sin proxy no hay git (política aceptada: soporta clones públicos, bloquea credenciales).
- `USER agent` SIEMPRE última línea del Dockerfile.

## Estado de los CLIs (quirks)
- codex: config TOML; `web_search = "disabled"` top-level obligatorio antes de tablas (los proveedores BYO no soportan tools hosted de la API Responses).
- kimi: binario único en `~/.kimi-code/bin/kimi` (installer `code.kimi.ai/kimi-code/install.sh`, canal global); se copia a `/usr/local/bin/kimi` por el HOME-mount; PATH mantiene `~/.kimi-code/bin` primero para que `kimi upgrade` en runtime gane. La nota de Git Bash es solo Windows (Linux ok sin git). Instalador legacy Python `kimi-cli` (code.kimi.com) deprecated.