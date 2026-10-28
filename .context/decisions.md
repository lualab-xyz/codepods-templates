# Decisiones (reglas persistentes)

1. **Imagen base compartida** en `ubuntu24/`; los Dockerfiles de agente parten con `FROM <image_base.name>` y declaran `image_base` en su manifest. La plataforma puede reescribir la FROM al vuelo.
2. **Nada de la capa común en imágenes de agente**; nada de agente en la base (ni ENTRYPOINT ni ENV de agente).
3. **Sin git en las imágenes** (ni base ni agentes): el proxy git es un script copiado a /usr/local/bin que instala un binario per-user en runtime; **al instalarlo elimina (no mueve/renombra) cualquier git real** (~/.local/bin/git, git.original del script antiguo, y best-effort /usr/bin, /usr/local/bin vía sudo -n); sin proxy no hay git (política: clones públicos ok, credenciales bloqueados).
4. **Node 22 LTS fijo** en la base (nodesource), con upgrade explícito tras el apt.
5. **$HOME se monta en runtime**: todo binario/fichero necesario en runtime va a paths de sistema en build (patrón: copiar a /usr/local/bin, conservar entrada PATH hacia el path de HOME para permitir upgrades de usuario).
6. **kimi canal global** (`code.kimi.ai/kimi-code/install.sh`) — no el legacy Python de code.kimi.com.
7. **codex**: `web_search = "disabled"` en el TOML generado (top-level, antes de tablas).
8. **Labels de imagen los genera la plataforma**; el repo no los declara.
9. Trabajo en ramas `feature/...`; no fusionar a main sin confirmación explícita del usuario.