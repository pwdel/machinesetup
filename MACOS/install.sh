#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This installer is for macOS only." >&2
  exit 1
fi

PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Projects}"
PYTHON_VERSION="${PYTHON_VERSION:-3.12}"
PYENV_INSTALL_VERSION="${PYENV_INSTALL_VERSION:-3.12.2}"
INSTALL_DOCKER="${INSTALL_DOCKER:-1}"
INSTALL_MULTIPASS="${INSTALL_MULTIPASS:-1}"
INSTALL_OPENCODE="${INSTALL_OPENCODE:-1}"
INSTALL_CODEX="${INSTALL_CODEX:-1}"
INSTALL_PUBLII="${INSTALL_PUBLII:-1}"
INSTALL_ITERM2="${INSTALL_ITERM2:-1}"
INSTALL_GIS="${INSTALL_GIS:-0}"
INSTALL_OBS="${INSTALL_OBS:-0}"

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

install_desktop_app() {
  local cask="$1"
  local bundle_id="$2"
  local app
  shift 2
  if ! brew list --cask "$cask" >/dev/null 2>&1; then
    for app in "$@"; do
      if [[ "$(plutil -extract CFBundleIdentifier raw "$app/Contents/Info.plist" 2>/dev/null)" == "$bundle_id" ]]; then
        printf 'Using the existing app at %s. Update it through its original installer.\n' "$app"
        return
      fi
    done
  fi
  brew install --cask "$cask"
}

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Xcode Command Line Tools are not installed. Launching the installer..." >&2
  xcode-select --install || true
  echo "Finish the Command Line Tools installation, then rerun this script." >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"
append_if_missing "$HOME/.zprofile" 'eval "$(/opt/homebrew/bin/brew shellenv)"'
append_if_missing "$HOME/.bash_profile" 'eval "$(/opt/homebrew/bin/brew shellenv)"'
append_if_missing "$HOME/.bashrc" 'eval "$(/opt/homebrew/bin/brew shellenv)"'

brew update
brew install ansible direnv uv go node pyenv pyenv-virtualenv pre-commit gettext tree gh ripgrep trufflehog doctl ossp-uuid k6 asciinema ffmpeg
installed_formulae="$(brew list --formula --full-name)"
if grep -Fxq terraform <<<"$installed_formulae"; then
  echo "Keeping the existing Homebrew Core Terraform. See MACOS/MACOS.md to switch to HashiCorp's package."
else
  brew install hashicorp/tap/terraform
fi

if [[ "$INSTALL_MULTIPASS" == "1" ]]; then
  brew install --cask multipass
fi

if [[ "$INSTALL_OPENCODE" == "1" ]]; then
  brew install opencode
fi

if [[ "$INSTALL_CODEX" == "1" ]]; then
  brew install --cask codex
fi

if [[ "$INSTALL_PUBLII" == "1" ]]; then
  install_desktop_app publii com.tidycustoms.publii /Applications/Publii.app "$HOME/Applications/Publii.app"
fi

if [[ "$INSTALL_ITERM2" == "1" ]]; then
  install_desktop_app iterm2 com.googlecode.iterm2 /Applications/iTerm.app "$HOME/Applications/iTerm.app"
fi

if [[ "$INSTALL_GIS" == "1" ]]; then
  brew install gdal poppler
  install_desktop_app qgis org.qgis.qgis3 /Applications/QGIS*.app "$HOME"/Applications/QGIS*.app
fi

if [[ "$INSTALL_OBS" == "1" ]]; then
  install_desktop_app obs com.obsproject.obs-studio /Applications/OBS.app "$HOME/Applications/OBS.app"
fi

if [[ "$INSTALL_DOCKER" == "1" ]]; then
  brew install --cask docker-desktop
fi

append_if_missing "$HOME/.zshrc" 'eval "$(direnv hook zsh)"'
append_if_missing "$HOME/.bashrc" 'eval "$(direnv hook bash)"'
append_if_missing "$HOME/.zshrc" 'export PATH="$HOME/.local/bin:$PATH"'
append_if_missing "$HOME/.bashrc" 'export PATH="$HOME/.local/bin:$PATH"'
append_if_missing "$HOME/.zshrc" 'export PATH="/opt/homebrew/opt/gettext/bin:$PATH"'
append_if_missing "$HOME/.bashrc" 'export PATH="/opt/homebrew/opt/gettext/bin:$PATH"'

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
  echo "Codex CLI installation appears to have failed." >&2
  exit 1
fi

if [[ -d "$PROJECTS_DIR/socialpredict" ]]; then
  mkdir -p "$PROJECTS_DIR/socialpredict/data/postgres" "$PROJECTS_DIR/socialpredict/data/certbot"
  chown -R "$(whoami)":staff "$PROJECTS_DIR/socialpredict/data"
fi

echo
echo "Install complete."
echo
echo "Next recommended steps:"
STEP=1
print_step 'Restart your shell or run: source ~/.zprofile && source ~/.zshrc'
print_step 'Generate a fresh UUID with: new_uuid'

if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  print_step 'If you need SSH access: ssh-keygen -t ed25519 -C "your_email@example.com" && eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519 && pbcopy < ~/.ssh/id_ed25519.pub'
fi

print_step "If you use safe: cd $PROJECTS_DIR/safe && pre-commit install && bash infra/scripts/bootstrap_mac.sh"
print_step "If you use mlx-test: cd $PROJECTS_DIR/mlx-test && direnv allow && uv sync && python -c \"import mlx.core as mx; print(mx.array([1, 2, 3]))\" && mlx-smoke-test && mlx-code-smoke-test"

if [[ "$INSTALL_OPENCODE" == "1" ]]; then
  print_step 'Verify OpenCode with: opencode --version'
fi

if [[ "$INSTALL_CODEX" == "1" ]]; then
  print_step 'Verify Codex with: codex --version'
fi

if [[ "$INSTALL_PUBLII" == "1" ]]; then
  print_step 'Open Publii and follow the editing guide in your website repository.'
fi

if [[ "$INSTALL_DOCKER" == "1" ]]; then
  print_step "If you use socialpredict: open Docker Desktop once, then cd $PROJECTS_DIR/socialpredict && mkdir -p data/postgres data/certbot && chown -R \"\$(whoami)\":staff data && ./SocialPredict install && ./SocialPredict up"
fi

print_step 'Try the shell helpers: safe-bootstrap && safe-vm'

echo
echo "Verification checklist:"
echo "  brew --version"
echo "  uuid -v 4"
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
if [[ "$INSTALL_GIS" == "1" ]]; then
  echo "  Open QGIS from Applications"
  echo "  gdalinfo --version"
  echo "  ogr2ogr --version"
  echo "  pdftoppm -v"
fi
echo "  rg --version"
echo "  asciinema --version"
echo "  ffmpeg -version"
echo "  ffprobe -version"
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
echo "  INSTALL_PUBLII=0"
echo "  INSTALL_ITERM2=0"
echo "  INSTALL_GIS=1"
echo "  INSTALL_OBS=1"
echo "  PYTHON_VERSION=3.12"
echo "  PYENV_INSTALL_VERSION=3.12.2"
echo
echo "Reference:"
echo "  $PROJECTS_DIR/machinesetup/MACOS/MACOS.md"
