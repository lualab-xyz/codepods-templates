# Todo global

- [ ] (User) Build y prueba de la base ubuntu24 y los 7 agentes tras el refactor (feature/base-image).
- [ ] (User) Verificar `which claude` en pod para descartar efecto HOME-mount del binario de claude.
- [ ] opencode: repro del fallo TMPDIR en su entorno (pendiente; en origin/test usa bash en TMUX como debug).
- [ ] Decidir destino de origin/test cuando se resuelva opencode.
- [ ] Dedup futuro posible: entrypoint.sh idéntico ×7 (destino con nombre distinto), stop-agent.sh 6/7, seed-config.sh 5/7.