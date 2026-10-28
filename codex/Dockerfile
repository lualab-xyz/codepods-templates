# Base image defined in ../ubuntu24 (see manifest.yml image_base)
FROM codepods-ubuntu24:latest

# ============================================================
# Agent-specific: OpenAI Codex CLI
# ============================================================
RUN npm install -g @openai/codex

COPY seed-config.sh /usr/local/bin/seed-config.sh
COPY entrypoint.sh /usr/local/bin/codex-entrypoint
COPY set-provider.sh /usr/local/bin/set-provider.sh
COPY add-mcp-server.sh /usr/local/bin/add-mcp-server.sh
COPY remove-mcp-server.sh /usr/local/bin/remove-mcp-server.sh
COPY add-skill.sh /usr/local/bin/add-skill.sh
COPY remove-skill.sh /usr/local/bin/remove-skill.sh
COPY get-mcps.sh /usr/local/bin/get-mcps.sh
COPY get-skills.sh /usr/local/bin/get-skills.sh
COPY start-agent.sh /usr/local/bin/start-agent.sh
COPY stop-agent.sh /usr/local/bin/stop-agent.sh
COPY files/ttyd/index.html /opt/ttyd/index.html
RUN chmod +x /usr/local/bin/seed-config.sh /usr/local/bin/codex-entrypoint /usr/local/bin/set-provider.sh /usr/local/bin/add-mcp-server.sh /usr/local/bin/remove-mcp-server.sh /usr/local/bin/add-skill.sh /usr/local/bin/remove-skill.sh /usr/local/bin/get-mcps.sh /usr/local/bin/get-skills.sh /usr/local/bin/start-agent.sh /usr/local/bin/stop-agent.sh \
    && chown -R agent:agent /home/agent

USER agent

ENTRYPOINT ["/usr/local/bin/codex-entrypoint"]
