#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This installer is for macOS only." >&2
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

brew_install_or_upgrade_cask() {
  local cask
  for cask in "$@"; do
    if brew list --cask "$cask" >/dev/null 2>&1; then
      brew upgrade --cask "$cask"
    else
      brew install --cask "$cask"
    fi
  done
}

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Xcode Command Line Tools are not installed. Run: xcode-select --install" >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"
append_if_missing "$HOME/.zprofile" 'eval "$(/opt/homebrew/bin/brew shellenv)"'

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
  brew_install_or_upgrade_cask docker docker-desktop multipass
fi

if [[ "$INSTALL_VAGRANT" == "1" ]]; then
  brew_install_or_upgrade_cask vagrant
fi

append_if_missing "$HOME/.zshrc" 'eval "$(direnv hook zsh)"'
append_if_missing "$HOME/.zshrc" 'export PATH="/opt/homebrew/opt/gettext/bin:$PATH"'

append_block_if_missing "$HOME/.zshrc" '# machinesetup-pyenv-init' "$(cat <<'EOF'
# machinesetup-pyenv-init
export PYENV_ROOT="$HOME/.pyenv"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
  eval "$(pyenv virtualenv-init -)"
fi
EOF
)"

uv python install "$PYTHON_VERSION"

if [[ -d "$PROJECTS_DIR/socialpredict" ]]; then
  mkdir -p "$PROJECTS_DIR/socialpredict/data/postgres" "$PROJECTS_DIR/socialpredict/data/certbot"
  chown -R "$(whoami)":staff "$PROJECTS_DIR/socialpredict/data"
fi

cat <<EOF

Install complete.

Next recommended steps:
  1. Restart your shell or run: source ~/.zprofile && source ~/.zshrc
  2. Run direnv allow in any project that uses a .envrc
  3. If Docker Desktop was installed, open it once before using an app that needs it

Reference:
  ~/Projects/machinesetup/MACOS/MACOS.md
EOF
