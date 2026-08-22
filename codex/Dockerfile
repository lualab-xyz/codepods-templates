FROM ubuntu:24.04

# ============================================================
# Common to all agent templates
# ============================================================
ENV TERM=tmux-256color
ENV LANG=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    curl nodejs npm nano git sudo ca-certificates gnupg tmux unzip \
    && rm -rf /var/lib/apt/lists/*

# ttyd — terminal web (static binary)
RUN curl -fsSL "https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64" \
    -o /usr/local/bin/ttyd && chmod +x /usr/local/bin/ttyd

COPY files/root/.tmux.conf /opt/tmux/.tmux.conf
COPY files/ttyd/index.html /opt/ttyd/index.html

COPY set-git-proxy.sh /usr/local/bin/set-git-proxy.sh
RUN chmod +x /usr/local/bin/set-git-proxy.sh

# Non-root user that runs the agent
RUN useradd -m -s /bin/bash agent \
    && mkdir -p /workspace /home/agent/.local/bin /home/agent/.config \
    && chown -R agent:agent /workspace

ENV HOME=/home/agent

WORKDIR /workspace

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
COPY start-agent.sh /usr/local/bin/start-agent.sh
COPY stop-agent.sh /usr/local/bin/stop-agent.sh
RUN chmod +x /usr/local/bin/seed-config.sh /usr/local/bin/codex-entrypoint /usr/local/bin/set-provider.sh /usr/local/bin/add-mcp-server.sh /usr/local/bin/remove-mcp-server.sh /usr/local/bin/add-skill.sh /usr/local/bin/remove-skill.sh /usr/local/bin/start-agent.sh /usr/local/bin/stop-agent.sh \
    && chown -R agent:agent /home/agent

USER agent

ENTRYPOINT ["/usr/local/bin/codex-entrypoint"]
