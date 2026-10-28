# Tarea actual

## Refactor: imagen base compartida (feature/base-image)
**Objetivo**: extraer la capa común de las 7 imágenes de agente a una imagen base `codepods-ubuntu24` (folder `ubuntu24/`), y declararla en manifests vía bloque `image_base` (posible reescritura de FROM al vuelo por el orquestador).

**Hecho**:
- `ubuntu24/` completo: Dockerfile + set-git-proxy.sh + files/root/.tmux.conf + files/ttyd/index.html (título genérico "CodePods Terminal").
- 7 Dockerfiles de agente reescritos: `FROM codepods-ubuntu24:latest` + parte agent-specific + COPY de su index.html.
- `image_base` añadido a los 7 manifest.yml.
- Los 14 ficheros comunes eliminados de los 7 templates (git los detectó como renames hacia ubuntu24/).
- README actualizado (base image, estructura, nuevo template).
- Validación: FROM ok ×7, COPY sources ok, manifests parsean.

**Estado**: implementado en rama `feature/base-image`, pendiente de build/prueba en la máquina del usuario (aquí no hay docker). NO fusionar a main sin confirmación del usuario.

## Pendiente (del usuario / bloqueados)
- Build `docker build -t codepods-ubuntu24:latest ./ubuntu24` + builds de agentes y prueba de pods en su máquina.
- Verificar `which claude` en un pod: sospecha de efecto HOME-mount sobre binary de claude (instalador escribe en $HOME?) — si falla, replicar el fix de kimi (cp a /usr/local/bin).
- opencode sigue fallando en su entorno con `TMPDIR`; su rama `origin/test` usa `bash` en TMUX en vez de `opencode` (debug suyo, no tocar). Queda pendiente encontrar repro mínimo (el intento de script de fallo no lo reprodujo).
- Decidir destino de rama `origin/test` (borrar o fusionar) cuando se resuelva opencode.

## Decisiones de sesión relacionadas
- Ver `decisions.md` (canal global kimi, kimi binario fuera de HOME, codex web_search, sin git en base).