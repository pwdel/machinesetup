# Linux Setup

This repo can also bootstrap a user-scoped AI coding setup on Linux.

The Linux path aims for the same toolset as macOS where practical, with Linux-native equivalents where needed.

## Baseline assumptions

- Host OS: Ubuntu or Debian
- Shell: `zsh`
- Projects root: `~/Projects`
- Homebrew prefix: `/home/linuxbrew/.linuxbrew`

## Machine-level prerequisites

Install baseline system packages:

```bash
sudo apt-get update
sudo apt-get install -y build-essential ca-certificates curl file git gnupg lsb-release procps unzip zsh
```

### Homebrew

Homebrew on Linux is used here to keep most tool names and versions aligned with the macOS setup.

```bash
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

### Core CLI tools

Install:

- `ansible`
- `asciinema`
- `dasel`
- `doctl`
- `direnv`
- `docker-buildx`
- `docker-compose`
- `ffmpeg`
- `uv`
- `uvw`
- `pyenv`
- `pyenv-virtualenv`
- `pre-commit`
- `gettext`
- `htop`
- `jq`
- `node`
- `tree`
- `gh`
- `go`
- `go-critic`
- `golangci-lint`
- `gosec`
- `staticcheck`
- `trufflehog`
- `terraform`
- `opencode`

```bash
brew tap hashicorp/tap
brew install \
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
```

## Docker

On Linux, the closest equivalent to Docker Desktop for most development work is Docker Engine from Docker's official apt repository.

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER"
```

Log out and back in after adding your user to the `docker` group.

## Shell configuration

### Homebrew

```bash
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zprofile
```

### direnv

```bash
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
```

### pyenv

```bash
cat <<'EOF' >> ~/.zshrc
# machinesetup-pyenv-init
export PYENV_ROOT="$HOME/.pyenv"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
  eval "$(pyenv virtualenv-init -)"
fi
EOF
```

### gettext / envsubst

```bash
echo 'export PATH="/home/linuxbrew/.linuxbrew/opt/gettext/bin:$PATH"' >> ~/.zshrc
```

## Python strategy

Prefer `uv` and `pyenv` over distro Python customization.

Recommended baseline:

```bash
uv python install 3.12
```

## AI coding tools

### Codex

- install the CLI via npm
- keep user-scoped config under `~/.codex`

```bash
npm install -g @openai/codex
```

### OpenCode

- install via Homebrew formula
- keep user-scoped config under `~/.config/opencode`

## Vagrant

Vagrant is optional:

```bash
sudo apt-get install -y vagrant
```

## One-shot installer

```bash
cd ~/Projects/machinesetup
bash LINUX/install.sh
```

The installer upgrades managed Homebrew formulas and refreshes Docker Engine packages when they are already installed.

Optional environment flags:

- `INSTALL_DOCKER=0`
- `INSTALL_VAGRANT=0`
- `INSTALL_CODEX=0`
- `PYTHON_VERSION=3.12`

## Verification checklist

- `brew --version`
- `ansible --version`
- `asciinema --version`
- `dasel --version`
- `doctl version`
- `direnv version`
- `docker buildx version`
- `docker compose version`
- `ffmpeg -version`
- `gh --version`
- `envsubst --version`
- `uv --version`
- `uvw --version`
- `pyenv --version`
- `pyenv virtualenv --version`
- `pre-commit --version`
- `htop --version`
- `jq --version`
- `node --version`
- `go version`
- `terraform version`
- `trufflehog --version`
- `staticcheck --version`
- `gosec --version`
- `golangci-lint version`
- `gocritic version`
- `opencode --version`
- `codex --version`
- `docker --version`
- `docker compose version`
- `vagrant --version`
