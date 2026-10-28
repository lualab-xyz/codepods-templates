# Base image defined in ../ubuntu24 (see manifest.yml image_base)
FROM codepods-ubuntu24:latest

# ============================================================
# Agent-specific: Anthropic Claude Code CLI
# ============================================================
RUN curl -fsSL https://claude.ai/install.sh | bash

COPY seed-config.sh /usr/local/bin/seed-config.sh
COPY entrypoint.sh /usr/local/bin/claude-entrypoint
COPY start-agent.sh /usr/local/bin/start-agent.sh
COPY add-mcp-server.sh /usr/local/bin/add-mcp-server.sh
COPY stop-agent.sh /usr/local/bin/stop-agent.sh
COPY files/ttyd/index.html /opt/ttyd/index.html
RUN chmod +x /usr/local/bin/seed-config.sh /usr/local/bin/claude-entrypoint /usr/local/bin/start-agent.sh /usr/local/bin/add-mcp-server.sh /usr/local/bin/stop-agent.sh \
    && chown -R agent:agent /home/agent

USER agent

ENTRYPOINT ["/usr/local/bin/claude-entrypoint"]
