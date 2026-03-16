#------------------------------------------------------------------------------
# Runtime
#------------------------------------------------------------------------------
FROM jdxcode/mise:2026.3 AS runtime

ARG CAPSULE_UID=1000
ARG CAPSULE_GID=100

WORKDIR /home/workspace

RUN install -m 0755 -d /etc/apt/keyrings && \
    . /etc/os-release && \
    DISTRO_ID="${ID}" && \
    DISTRO_CODENAME="${VERSION_CODENAME:-${UBUNTU_CODENAME:-}}" && \
    curl -fsSL "https://download.docker.com/linux/${DISTRO_ID}/gpg" | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) " \
    "signed-by=/etc/apt/keyrings/docker.gpg] " \
    "https://download.docker.com/linux/${DISTRO_ID} " \
    "${DISTRO_CODENAME} stable" \
    > /etc/apt/sources.list.d/docker.list && \
    curl -fsSL \
    https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    -o /etc/apt/keyrings/github-cli.gpg && \
    chmod a+r /etc/apt/keyrings/github-cli.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) " \
    "signed-by=/etc/apt/keyrings/github-cli.gpg] " \
    "https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    docker-buildx-plugin docker-ce-cli docker-compose-plugin \
    ca-certificates curl fd-find gh git gnupg jq less ripgrep \
    shellcheck sudo tree vim && \
    ln -sf /usr/bin/fdfind /usr/local/bin/fd && \
    rm -rf /var/lib/apt/lists/*

# Add user (reuse existing group when GID already exists)
RUN if ! getent group "${CAPSULE_GID}" >/dev/null 2>&1; then \
      groupadd -g "${CAPSULE_GID}" capsule; \
    fi && \
    useradd -m -u "${CAPSULE_UID}" \
      -g "${CAPSULE_GID}" -s /bin/bash user

# Initialize mise root for 'user'
RUN mkdir -p /mise && chown -Rh user: /mise

# Automatically activate mise
RUN echo 'eval "$(mise activate bash)"' >> /etc/profile

# Copy entrypoint (owned by root for security)
COPY docker/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch user
USER user

# Use a common AGENTS.md in the direct parent of `workspace`
COPY docker/AGENTS.md /home/

# Install nodejs
RUN mise use -g node@24
RUN mise install

# Install golang
RUN mise use -g golang@1.26

# Install Codex
RUN npm install -g @openai/codex open-codex

# Install Copilot and vim extension
RUN npm install -g @github/copilot

# Entrypoint runs as root, adjusts UID/GID, drops privileges
USER root
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash", "-l"]
