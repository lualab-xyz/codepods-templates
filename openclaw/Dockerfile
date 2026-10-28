# Base image defined in ../ubuntu24 (see manifest.yml image_base)
FROM codepods-ubuntu24:latest

# ============================================================
# Agent-specific: OpenClaw gateway
# ============================================================
# OpenClaw requires Node 22.22.3+ (satisfied by Node 22 LTS in the base image)
RUN npm install -g openclaw@latest

COPY seed-config.sh /usr/local/bin/seed-config.sh
COPY entrypoint.sh /usr/local/bin/openclaw-entrypoint
COPY set-provider.sh /usr/local/bin/set-provider.sh
COPY add-mcp-server.sh /usr/local/bin/add-mcp-server.sh
COPY start-agent.sh /usr/local/bin/start-agent.sh
COPY stop-agent.sh /usr/local/bin/stop-agent.sh
COPY files/ttyd/index.html /opt/ttyd/index.html
RUN chmod +x /usr/local/bin/seed-config.sh /usr/local/bin/openclaw-entrypoint /usr/local/bin/set-provider.sh /usr/local/bin/add-mcp-server.sh /usr/local/bin/start-agent.sh /usr/local/bin/stop-agent.sh \
    && chown -R agent:agent /home/agent

USER agent

ENTRYPOINT ["/usr/local/bin/openclaw-entrypoint"]
