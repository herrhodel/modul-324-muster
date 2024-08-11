# Pull the minimal Ubuntu image
FROM ubuntu:24.10

# Install Nginx
RUN apt-get -y update \
  && apt-get -y install nginx git curl gnupg software-properties-common --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# Copy the Nginx config
COPY default /etc/nginx/sites-available/default
# Copy the HTML to the image
COPY src/* /usr/share/nginx/html

# Expose the port for access
EXPOSE 3000/tcp

# Run the Nginx server
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]

# --- Same as Dockerfile until here...

# Install dev dependencies

SHELL ["/bin/bash", "-c"]

## Common tools
RUN apt-get -y update && apt-get -y install jq less openssl openssh-client gpg wget zip unzip autoconf patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev --no-install-recommends

## AWS CLI Apple Silicon
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install

# RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
#   && unzip awscliv2.zip \
#   && ./aws/install

## Terraform 1.9.2
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null \
  && gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint \
  && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com bookworm main" | tee /etc/apt/sources.list.d/hashicorp.list \
  && apt-get update && apt-get -y install terraform=1.9.2-* --no-install-recommends

## Kamal via mise and ruby
RUN curl https://mise.run | sh \
  && echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc \
  && ~/.local/bin/mise use --global ruby@3.2.2 \
  && ~/.local/share/mise/installs/ruby/3.2.2/bin/gem install kamal

# Funky Terminal
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
  -t https://github.com/denysdovhan/spaceship-prompt \
  && curl -sS https://starship.rs/install.sh | sh -s - --yes \
  && echo 'eval "$(starship init bash)"' >> ~/.bashrc \
  && echo 'eval "$(starship init zsh)"' >> ~/.zshrc \
  && echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc \



