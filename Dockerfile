# OpenCode Docker Environment
# Base: Node.js 22 on Debian 12 (Bookworm)
# Includes: OpenCode, Atlassian CLI, dev tools, shared caches

FROM node:22-bookworm

LABEL maintainer="OpenCode Docker Setup"
LABEL description="Docker environment for OpenCode AI agent with shared tooling across projects"

# Default entry point: bash shell that launches OpenCode by default.
# Override the command (e.g. `-c "..."`, or `-ic` for a shell) for ad-hoc tasks.
ENTRYPOINT ["/bin/bash"]
CMD ["-c", "opencode"]

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Essential tools
    git \
    curl \
    wget \
    ca-certificates \
    gnupg2 \
    # JSON processing and searching
    jq \
    ripgrep \
    # Fuzzy finder
    fzf \
    # Document conversion
    pandoc \
    # GitHub CLI
    gh \
    # Python runtime and build tools
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    libssl-dev \
    libffi-dev \
    # Utilities
    less \
    openssh-client \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Atlassian CLI via official Debian repository
RUN mkdir -p -m 755 /etc/apt/keyrings && \
    wget -nv -O- https://acli.atlassian.com/gpg/public-key.asc | gpg --dearmor -o /etc/apt/keyrings/acli-archive-keyring.gpg && \
    chmod go+r /etc/apt/keyrings/acli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/acli-archive-keyring.gpg] https://acli.atlassian.com/linux/deb stable main" | tee /etc/apt/sources.list.d/acli.list > /dev/null && \
    apt-get update && apt-get install -y acli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create cache and config directories (as root) before any npm operations
RUN mkdir -p /home/node/.npm \
    /home/node/.npm-global \
    /home/node/.cache/pip \
    /home/node/.config/opencode \
    && chown -R node:node /home/node

# Add node user to dialout group to handle mounted volumes owned by dialout
RUN usermod -a -G dialout node || true

# Switch to non-root user before npm operations so installs are node-owned
USER node
WORKDIR /workspace

# Configure Git for OpenCode commits
RUN git config --global user.name "Jonathan Diehl" && \
    git config --global user.email "1334574+jdiehl@users.noreply.github.co"

# Set environment
ENV PATH="/home/node/.npm-global/bin:/usr/local/bin:$PATH"
ENV NPM_CONFIG_CACHE="/home/node/.npm"
ENV PIP_CACHE_DIR="/home/node/.cache/pip"

# Configure npm cache and global prefix in node's user npmrc (~/.npmrc)
RUN npm config set cache /home/node/.npm && \
    npm config set prefix /home/node/.npm-global

# Install OpenCode globally (as node, into node-owned prefix)
RUN npm install -g opencode-ai@latest

# Verify installation
RUN which git curl jq opencode && echo "✓ All tools installed"

# Copy opencode config
COPY --chown=node:node config/opencode.jsonc /home/node/.config/opencode/opencode.jsonc
