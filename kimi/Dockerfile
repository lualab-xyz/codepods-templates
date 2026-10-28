# Base image defined in ../ubuntu24 (see manifest.yml image_base)
FROM codepods-ubuntu24:latest

# ============================================================
# Agent-specific: Moonshot Kimi Code CLI
# ============================================================
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
COPY files/ttyd/index.html /opt/ttyd/index.html
RUN chmod +x /usr/local/bin/seed-config.sh /usr/local/bin/kimi-entrypoint /usr/local/bin/set-provider.sh /usr/local/bin/add-mcp-server.sh /usr/local/bin/start-agent.sh /usr/local/bin/stop-agent.sh \
    && chown -R agent:agent /home/agent

USER agent

ENTRYPOINT ["/usr/local/bin/kimi-entrypoint"]
