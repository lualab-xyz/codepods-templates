FROM ubuntu:24.04

# ============================================================
# Common to all agent templates
# ============================================================
ENV TERM=tmux-256color
ENV LANG=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    curl nodejs npm nano git sudo ca-certificates gnupg tmux \
    && rm -rf /var/lib/apt/lists/*

# ttyd — terminal web (static binary)
RUN curl -fsSL "https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64" \
    -o /usr/local/bin/ttyd && chmod +x /usr/local/bin/ttyd

COPY files/root/.tmux.conf /root/.tmux.conf
COPY files/ttyd/index.html /opt/ttyd/index.html

COPY set-git-proxy.sh /usr/local/bin/set-git-proxy.sh
RUN chmod +x /usr/local/bin/set-git-proxy.sh

# Non-root user that runs the agent
RUN useradd -m -s /bin/bash agent \
    && mkdir -p /workspace /home/agent/.local/bin /home/agent/.config \
    && chown -R agent:agent /workspace \
    && cp /root/.tmux.conf /home/agent/.tmux.conf \
    && chown agent:agent /home/agent/.tmux.conf

ENV HOME=/home/agent

WORKDIR /workspace

# ============================================================
# Agent-specific: OpenAI Codex CLI
# ============================================================
RUN npm install -g @openai/codex

RUN mkdir -p /home/agent/.codex
COPY files/root/.codex/config.toml /home/agent/.codex/config.toml

COPY entrypoint.sh /usr/local/bin/codex-entrypoint
COPY set-provider.sh /usr/local/bin/set-provider.sh
COPY add-mcp-server.sh /usr/local/bin/add-mcp-server.sh
COPY start-agent.sh /usr/local/bin/start-agent.sh
COPY stop-agent.sh /usr/local/bin/stop-agent.sh
RUN chmod +x /usr/local/bin/codex-entrypoint /usr/local/bin/set-provider.sh /usr/local/bin/add-mcp-server.sh /usr/local/bin/start-agent.sh /usr/local/bin/stop-agent.sh \
    && chown -R agent:agent /home/agent

USER agent

ENTRYPOINT ["/usr/local/bin/codex-entrypoint"]
