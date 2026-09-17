FROM ubuntu:24.04

# ============================================================
# Common to all agent templates
# ============================================================
ENV TERM=tmux-256color
ENV LANG=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    curl nodejs npm nano sudo ca-certificates gnupg tmux unzip \
    && rm -rf /var/lib/apt/lists/*

# Node 22 LTS (common upgrade from apt Node 18)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
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
# Agent-specific: Moonshot Kimi Code CLI
# ============================================================
ENV PATH="/home/agent/.local/bin:${PATH}"

# Kimi Code CLI — single binary, no Python/uv needed. The legacy
# code.kimi.com/install.sh (Python "kimi-cli") is deprecated; its warning
# points at this installer. The global channel (code.kimi.ai) makes the
# installer write region "global" instead of "mainland-cn".
# The installer drops the binary in ~/.kimi-code/bin/kimi, but the platform
# mounts a volume over $HOME at runtime that replaces build-time contents
# (see seed-config.sh), which would hide it — the original "kimi: command
# not found" bug. So the binary is copied to /usr/local/bin (system path,
# outside the HOME mount). The PATH entry for ~/.kimi-code/bin is kept
# BEFORE /usr/local/bin so a user-space `kimi upgrade` (which writes into
# the runtime volume) takes precedence over the build-time copy.
ENV PATH="/home/agent/.kimi-code/bin:${PATH}"
RUN curl -fsSL https://code.kimi.ai/kimi-code/install.sh | KIMI_NO_MODIFY_PATH=1 bash \
    && cp /home/agent/.kimi-code/bin/kimi /usr/local/bin/kimi \
    && kimi --version

COPY seed-config.sh /usr/local/bin/seed-config.sh
COPY entrypoint.sh /usr/local/bin/kimi-entrypoint
COPY set-provider.sh /usr/local/bin/set-provider.sh
COPY add-mcp-server.sh /usr/local/bin/add-mcp-server.sh
COPY start-agent.sh /usr/local/bin/start-agent.sh
COPY stop-agent.sh /usr/local/bin/stop-agent.sh
RUN chmod +x /usr/local/bin/seed-config.sh /usr/local/bin/kimi-entrypoint /usr/local/bin/set-provider.sh /usr/local/bin/add-mcp-server.sh /usr/local/bin/start-agent.sh /usr/local/bin/stop-agent.sh \
    && chown -R agent:agent /home/agent

USER agent

ENTRYPOINT ["/usr/local/bin/kimi-entrypoint"]
