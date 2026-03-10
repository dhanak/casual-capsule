# syntax=docker/dockerfile:1
# check=skip=SecretsUsedInArgOrEnv

ARG DEBIAN_VERSION=trixie

#------------------------------------------------------------------------------
# Runtime
#------------------------------------------------------------------------------
FROM debian:${DEBIAN_VERSION}-slim AS runtime

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# https://docs.docker.com/build/cache/
RUN --mount=type=cache,id=apt-global,sharing=locked,target=/var/cache/apt \
    apt-get update && \
    apt-get -y --no-install-recommends install \
    bash-completion build-essential busybox ca-certificates curl git gnupg \
    openssh-client procps shellcheck sudo tree unzip vim zip && \
    rm -rf /var/lib/apt/lists/* && \
    busybox --install -s

WORKDIR /home/workspace

# setup docker
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

RUN --mount=type=cache,id=apt-global,sharing=locked,target=/var/cache/apt \
    apt-get update && \
    apt-get -y --no-install-recommends install \
    docker-buildx-plugin docker-ce-cli docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Add user
RUN groupadd -g 1000 user && useradd -m -u 1000 -g 1000 -s /bin/bash user

# set mise paths
ENV MISE_DATA_DIR="/mise"
ENV MISE_CONFIG_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
ENV PATH="/mise/shims:$PATH"

# Initialize mise root for 'user'
RUN mkdir -p /mise && chown -Rh user: /mise
COPY --chown=user docker/mise.toml /mise/config.toml

# Install mise
RUN curl https://mise.run | sh

# Automatically activate mise
RUN echo 'eval "$(mise activate bash)"' >> /etc/profile
RUN echo 'eval "$(mise complete bash)"' >> /etc/profile

# Switch user
USER user

# Copy GITHUB_API_TOKEN from builder env
ARG GITHUB_API_TOKEN=""
ENV GITHUB_API_TOKEN=${GITHUB_API_TOKEN}

# Install mise and tools
RUN mise install

# Install Copilot and vim extension
RUN npm install -g @github/copilot

# Use a common AGENTS.md in the direct parent of `workspace`
COPY --chmod=644 docker/AGENTS.md /home/

# By default start a shell
CMD [ "/bin/bash", "-il" ]
