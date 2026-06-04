#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This installer is for Linux only." >&2
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  echo "Cannot determine Linux distribution." >&2
  exit 1
fi

. /etc/os-release

if [[ "${ID:-}" != "ubuntu" && "${ID:-}" != "debian" ]]; then
  echo "This installer currently supports Ubuntu and Debian." >&2
  exit 1
fi

PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Projects}"
PYTHON_VERSION="${PYTHON_VERSION:-3.12}"
INSTALL_DOCKER="${INSTALL_DOCKER:-1}"
INSTALL_VAGRANT="${INSTALL_VAGRANT:-1}"
INSTALL_CODEX="${INSTALL_CODEX:-1}"

append_if_missing() {
  local file="$1"
  local line="$2"
  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    printf '%s\n' "$line" >>"$file"
  fi
}

append_block_if_missing() {
  local file="$1"
  local marker="$2"
  local block="$3"
  touch "$file"
  if ! grep -Fq "$marker" "$file"; then
    printf '\n%s\n' "$block" >>"$file"
  fi
}

brew_install_or_upgrade_formula() {
  local formula
  for formula in "$@"; do
    if brew list --formula "$formula" >/dev/null 2>&1; then
      brew upgrade "$formula"
    else
      brew install "$formula"
    fi
  done
}

install_docker_engine() {
  if command -v docker >/dev/null 2>&1; then
    echo "Docker already present; upgrading Docker Engine packages if updates are available."
  fi

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/"$ID"/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  local arch
  arch="$(dpkg --print-architecture)"

  echo \
    "deb [arch=${arch} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${ID} \
    ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker "$USER" || true
}

sudo apt-get update
sudo apt-get install -y \
  build-essential \
  ca-certificates \
  curl \
  file \
  git \
  gnupg \
  lsb-release \
  procps \
  unzip \
  zsh

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
append_if_missing "$HOME/.profile" 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
append_if_missing "$HOME/.zprofile" 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'

brew update
brew tap hashicorp/tap
brew_install_or_upgrade_formula \
  ansible \
  asciinema \
  dasel \
  doctl \
  direnv \
  docker-buildx \
  docker-compose \
  ffmpeg \
  gh \
  gettext \
  go \
  go-critic \
  golangci-lint \
  gosec \
  htop \
  jq \
  node \
  opencode \
  pre-commit \
  pyenv \
  pyenv-virtualenv \
  staticcheck \
  hashicorp/tap/terraform \
  tree \
  trufflehog \
  uv \
  uvw

if [[ "$INSTALL_CODEX" == "1" ]]; then
  npm install -g @openai/codex
fi

if [[ "$INSTALL_DOCKER" == "1" ]]; then
  install_docker_engine
fi

if [[ "$INSTALL_VAGRANT" == "1" ]]; then
  sudo apt-get install -y vagrant
fi

append_if_missing "$HOME/.zshrc" 'eval "$(direnv hook zsh)"'

append_block_if_missing "$HOME/.zshrc" '# machinesetup-pyenv-init' "$(cat <<'EOF'
# machinesetup-pyenv-init
export PYENV_ROOT="$HOME/.pyenv"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
  eval "$(pyenv virtualenv-init -)"
fi
EOF
)"

append_if_missing "$HOME/.zshrc" 'export PATH="/home/linuxbrew/.linuxbrew/opt/gettext/bin:$PATH"'

uv python install "$PYTHON_VERSION"

cat <<EOF

Install complete.

Next recommended steps:
  1. Restart your shell or run: source ~/.profile && source ~/.zshrc
  2. Run direnv allow in any project that uses a .envrc
  3. If Docker was installed, log out and back in before using an app that needs Docker group access

Reference:
  ~/Projects/machinesetup/LINUX/LINUX.md
EOF
