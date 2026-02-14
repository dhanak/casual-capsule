#------------------------------------------------------------------------------
# Runtime
#------------------------------------------------------------------------------
FROM jdxcode/mise:2026.2 AS runtime
WORKDIR /app
RUN apt-get update && apt-get full-upgrade -y
RUN apt-get install -y --no-install-recommends git vim sudo

# Add user
RUN useradd -g 100 -m -u 8888 b

# Set up ownership in home
RUN mkdir -p /home/b/.codex /home/b/.config /home/b/.local/share/gh && chown b: -Rh /home/b

# Initialize mise root for 'b'
RUN mkdir -p /mise && chown -Rh b: /mise

# Automatically activate mise
RUN echo 'eval "$(mise activate bash)"' >> /etc/profile

# Switch user
USER b

# Install nodejs
RUN mise use -g node@latest
RUN mise install node@24

# Install golang
RUN mise use -g golang@latest

# Install Codex
RUN npm -g install @openai/codex open-codex

# Install Copilot and vim extension
RUN npm -g install @github/copilot
RUN mkdir -p /home/b/.vim/pack/github/start && \
      git clone https://github.com/github/copilot.vim \
        /home/b/.vim/pack/github/start/copilot.vim

## Install forge
#RUN npx forgecode@latest

# Remove mise's original entrypoint
ENTRYPOINT []

# Finalize installation/configuration
RUN mkdir -p ~/.codex && echo '{ "model": "o4-mini" }' > ~/.codex/config.json

# By default start CLI
CMD [ "/bin/bash" ]
#CMD [ "codex" ]
#CMD [ "copilot" ]
