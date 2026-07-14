#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This installer is for Linux only." >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This Linux installer currently targets apt-based distributions." >&2
  exit 1
fi

PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Projects}"
PYTHON_VERSION="${PYTHON_VERSION:-3.12}"
PYENV_INSTALL_VERSION="${PYENV_INSTALL_VERSION:-3.12.2}"
INSTALL_DOCKER="${INSTALL_DOCKER:-1}"
INSTALL_MULTIPASS="${INSTALL_MULTIPASS:-1}"
INSTALL_OPENCODE="${INSTALL_OPENCODE:-1}"
INSTALL_CODEX="${INSTALL_CODEX:-1}"

if [[ ${EUID} -eq 0 ]]; then
  SUDO=()
  TARGET_USER="${SUDO_USER:-root}"
else
  if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo is required when running as a non-root user." >&2
    exit 1
  fi
  SUDO=(sudo)
  TARGET_USER="${USER}"
fi

TARGET_GROUP="$(id -gn "$TARGET_USER")"

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

print_step() {
  printf '  %d. %s\n' "$STEP" "$1"
  STEP=$((STEP + 1))
}

detect_brew_bin() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return 0
  fi

  if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    echo /home/linuxbrew/.linuxbrew/bin/brew
    return 0
  fi

  if [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
    echo "$HOME/.linuxbrew/bin/brew"
    return 0
  fi

  return 1
}

"${SUDO[@]}" apt-get update
"${SUDO[@]}" apt-get install -y \
  build-essential \
  curl \
  file \
  git \
  procps \
  ca-certificates \
  unzip \
  xz-utils \
  make \
  gettext \
  libssl-dev \
  zlib1g-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev \
  libffi-dev \
  liblzma-dev \
  tk-dev \
  libncursesw5-dev

if [[ "$INSTALL_MULTIPASS" == "1" ]] && ! command -v snap >/dev/null 2>&1; then
  "${SUDO[@]}" apt-get install -y snapd
fi

BREW_BIN="$(detect_brew_bin || true)"

if [[ -z "$BREW_BIN" ]]; then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  BREW_BIN="$(detect_brew_bin || true)"
fi

if [[ -z "$BREW_BIN" ]]; then
  echo "Homebrew installation failed." >&2
  exit 1
fi

eval "$("$BREW_BIN" shellenv)"
BREW_SHELLENV_LINE="eval \"\$($BREW_BIN shellenv)\""
append_if_missing "$HOME/.profile" "$BREW_SHELLENV_LINE"
append_if_missing "$HOME/.bashrc" "$BREW_SHELLENV_LINE"
append_if_missing "$HOME/.zprofile" "$BREW_SHELLENV_LINE"

brew update
brew install ansible direnv uv go node pyenv pyenv-virtualenv pre-commit gettext tree gh trufflehog terraform doctl ossp-uuid k6

if [[ "$INSTALL_OPENCODE" == "1" ]]; then
  brew install opencode
fi

if [[ "$INSTALL_CODEX" == "1" ]]; then
  npm install -g @openai/codex
fi

if [[ "$INSTALL_MULTIPASS" == "1" ]]; then
  if ! command -v snap >/dev/null 2>&1; then
    echo "snap is required to install Multipass on Linux." >&2
    exit 1
  fi

  if command -v systemctl >/dev/null 2>&1; then
    "${SUDO[@]}" systemctl enable --now snapd.socket || true
  fi

  if [[ ! -e /snap ]] && [[ -d /var/lib/snapd/snap ]]; then
    "${SUDO[@]}" ln -s /var/lib/snapd/snap /snap
  fi

  if ! snap list multipass >/dev/null 2>&1; then
    "${SUDO[@]}" snap install multipass
  fi
fi

if [[ "$INSTALL_DOCKER" == "1" ]] && ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | "${SUDO[@]}" sh
fi

if [[ "$INSTALL_DOCKER" == "1" ]] && getent group docker >/dev/null 2>&1; then
  if ! id -nG "$TARGET_USER" | grep -qw docker; then
    "${SUDO[@]}" usermod -aG docker "$TARGET_USER"
  fi
fi

GETTEXT_BIN="$("$BREW_BIN" --prefix gettext)/bin"
append_if_missing "$HOME/.zshrc" 'eval "$(direnv hook zsh)"'
append_if_missing "$HOME/.bashrc" 'eval "$(direnv hook bash)"'
append_if_missing "$HOME/.zshrc" 'export PATH="$HOME/.local/bin:$PATH"'
append_if_missing "$HOME/.bashrc" 'export PATH="$HOME/.local/bin:$PATH"'
append_if_missing "$HOME/.zshrc" "export PATH=\"$GETTEXT_BIN:\$PATH\""
append_if_missing "$HOME/.bashrc" "export PATH=\"$GETTEXT_BIN:\$PATH\""

append_block_if_missing "$HOME/.zshrc" '# machinesetup-uuid-tools' "$(cat <<'EOF'
# machinesetup-uuid-tools
new_uuid() {
  uuid -v 4
}
EOF
)"

append_block_if_missing "$HOME/.bashrc" '# machinesetup-uuid-tools' "$(cat <<'EOF'
# machinesetup-uuid-tools
new_uuid() {
  uuid -v 4
}
EOF
)"

append_block_if_missing "$HOME/.zshrc" '# machinesetup-pyenv-init' "$(cat <<'EOF'
# machinesetup-pyenv-init
export PYENV_ROOT="$HOME/.pyenv"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
  eval "$(pyenv virtualenv-init -)"
fi
EOF
)"

append_block_if_missing "$HOME/.bashrc" '# machinesetup-pyenv-init' "$(cat <<'EOF'
# machinesetup-pyenv-init
export PYENV_ROOT="$HOME/.pyenv"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - bash)"
  eval "$(pyenv virtualenv-init -)"
fi
EOF
)"

append_block_if_missing "$HOME/.zshrc" '# safe-vm-tools' "$(cat <<'EOF'
# safe-vm-tools
alias mp='multipass'
alias ap='ansible-playbook'
alias safe-bootstrap='bash "$HOME/Projects/safe/infra/scripts/bootstrap_mac.sh"'
alias safe-vm='bash "$HOME/Projects/safe/infra/scripts/mp-shell.sh"'
EOF
)"

append_block_if_missing "$HOME/.bashrc" '# safe-vm-tools' "$(cat <<'EOF'
# safe-vm-tools
alias mp='multipass'
alias ap='ansible-playbook'
alias safe-bootstrap='bash "$HOME/Projects/safe/infra/scripts/bootstrap_mac.sh"'
alias safe-vm='bash "$HOME/Projects/safe/infra/scripts/mp-shell.sh"'
EOF
)"

uv python install "$PYTHON_VERSION"
pyenv install -s "$PYENV_INSTALL_VERSION"
PYENV_PYTHON="$(pyenv root)/versions/$PYENV_INSTALL_VERSION/bin/python"
uv pip install --python "$PYENV_PYTHON" --upgrade PyYAML

mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
TMP_GO_BIN="$(mktemp -d)"
GOBIN="$TMP_GO_BIN" go install github.com/getkin/kin-openapi/cmd/validate@latest
install -m 0755 "$TMP_GO_BIN/validate" "$HOME/.local/bin/kin-openapi-validate"
rm -rf "$TMP_GO_BIN"
uv tool install --upgrade --force schemathesis

if ! command -v uuid >/dev/null 2>&1; then
  echo "ossp-uuid installation appears to have failed." >&2
  exit 1
fi

if ! command -v k6 >/dev/null 2>&1; then
  echo "k6 installation appears to have failed." >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "Node installation appears to have failed." >&2
  exit 1
fi

if ! "$PYENV_PYTHON" -c 'import yaml' >/dev/null 2>&1; then
  echo "PyYAML installation appears to have failed." >&2
  exit 1
fi

if [[ "$INSTALL_OPENCODE" == "1" ]] && ! command -v opencode >/dev/null 2>&1; then
  echo "OpenCode installation appears to have failed." >&2
  exit 1
fi

if [[ "$INSTALL_CODEX" == "1" ]] && ! command -v codex >/dev/null 2>&1; then
  echo "Codex installation appears to have failed." >&2
  exit 1
fi

if [[ -d "$PROJECTS_DIR/socialpredict" ]]; then
  mkdir -p "$PROJECTS_DIR/socialpredict/data/postgres" "$PROJECTS_DIR/socialpredict/data/certbot"
  chown -R "$TARGET_USER":"$TARGET_GROUP" "$PROJECTS_DIR/socialpredict/data"
fi

echo
echo "Install complete."
echo
echo "Next recommended steps:"
STEP=1
print_step 'Restart your shell or run: source ~/.profile && source ~/.bashrc && source ~/.zshrc'
print_step 'Generate a fresh UUID with: new_uuid'

if [[ "$INSTALL_DOCKER" == "1" ]]; then
  print_step 'Log out and back in once so docker group membership takes effect'
fi

if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  print_step 'If you need SSH access: ssh-keygen -t ed25519 -C "your_email@example.com" && eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519 && cat ~/.ssh/id_ed25519.pub'
fi

print_step "If you use safe: cd $PROJECTS_DIR/safe && pre-commit install && bash infra/scripts/bootstrap_mac.sh"
print_step "If you use mlx-test: cd $PROJECTS_DIR/mlx-test && direnv allow && uv sync && python -c \"import mlx.core as mx; print(mx.array([1, 2, 3]))\" && mlx-smoke-test && mlx-code-smoke-test"

if [[ "$INSTALL_OPENCODE" == "1" ]]; then
  print_step 'Verify OpenCode with: opencode --version'
fi

if [[ "$INSTALL_CODEX" == "1" ]]; then
  print_step 'Verify Codex with: codex --version'
fi

if [[ "$INSTALL_DOCKER" == "1" ]]; then
  print_step "If you use socialpredict: cd $PROJECTS_DIR/socialpredict && mkdir -p data/postgres data/certbot && chown -R \"$TARGET_USER\":\"$TARGET_GROUP\" data && ./SocialPredict install && ./SocialPredict up"
fi

print_step 'Try the shell helpers: safe-bootstrap && safe-vm'

echo
echo "Verification checklist:"
echo "  uuid -v 4"
echo "  brew --version"
echo "  direnv version"
echo "  uv --version"
echo "  go version"
echo "  node --version"
echo "  pyenv --version"
echo "  $PYENV_PYTHON -c 'import yaml'"
echo "  pre-commit --version"
if [[ "$INSTALL_OPENCODE" == "1" ]]; then
  echo "  opencode --version"
fi
echo "  ansible --version"
if [[ "$INSTALL_CODEX" == "1" ]]; then
  echo "  codex --version"
fi
if [[ "$INSTALL_DOCKER" == "1" ]]; then
  echo "  docker --version"
  echo "  docker compose version"
fi
if [[ "$INSTALL_MULTIPASS" == "1" ]]; then
  echo "  multipass version"
fi
echo "  trufflehog --version"
echo "  terraform version"
echo "  doctl version"
echo "  k6 version"
echo "  kin-openapi-validate --help"
echo "  schemathesis --version"
echo
echo "Optional environment flags:"
echo "  PROJECTS_DIR=~/Projects"
echo "  INSTALL_DOCKER=0"
echo "  INSTALL_MULTIPASS=0"
echo "  INSTALL_OPENCODE=0"
echo "  INSTALL_CODEX=0"
echo "  PYTHON_VERSION=3.12"
echo "  PYENV_INSTALL_VERSION=3.12.2"
echo
echo "Reference:"
echo "  $PROJECTS_DIR/machinesetup/LINUX/LINUX.md"
