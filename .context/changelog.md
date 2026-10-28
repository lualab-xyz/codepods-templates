# Changelog

## main / dev
- `228f5d7` (en `dev` y `main`): **solo** la carpeta `ubuntu24/` (Dockerfile + assets), entregada para que el host pueda construir/cache-ear `codepods-ubuntu24:latest` antes de que llegue el resto del refactor. Los Dockerfiles de agente y manifests en dev/main quedan SIN CAMBIAR.
- El resto del refactor (Dockerfiles agent, manifests con image_base, README, set-git-proxy deletión) sigue solo en `feature/base-image` (`8f42989`) a la espera de confirmación.

## feature/base-image (en curso)
- `set-git-proxy.sh` (ahora compartido en ubuntu24/): ya no respalda el git real a `git.original`; lo **elimina** (junto con backups antiguos) e intenta borrar /usr/bin/git y /usr/local/bin/git si aparecieran (best-effort por sudo -n).
- Nuevo folder `ubuntu24/` con la imagen base común Dockerfile + assets (set-git-proxy.sh, .tmux.conf, index.html ttyd genérico). Node 22 LTS en base; sin git.
- 7 Dockerfiles de agente reescritos: `FROM codepods-ubuntu24:latest` + solo parte agent-specific; cada uno copia su propio `files/ttyd/index.html` sobre `/opt/ttyd`.
- 14 ficheros comunes eliminados de los 7 templates (set-git-proxy.sh, files/root/.tmux.conf).
- `image_base { name/repository/branch/folder/dockerfile }` añadido a los 7 manifest.yml (`branch: "main"` por defecto, pedido a posteriori).
- README: sección "Base image", estructura y pasos para plantilla nueva actualizados.
- Creada documentación de contexto `.context/` (design, task, decisions, todo).

## main (post-merge 6507a79)
- Integración de rama fix: canal global kimi, kimi binario en /usr/local/bin, web_search disabled en codex, sin git en los 7, resolución de conflicto TMPDIR en opencode/start-agent.sh (export incondicional + chmod 700).