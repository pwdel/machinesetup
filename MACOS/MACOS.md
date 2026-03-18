# MacOS Setup

This repo is a portable, versioned simulation of a user-scoped AI coding setup on macOS.

The long-term target is still a real user-scoped machine configuration such as:

- `~/.codex`
- `~/.config/opencode`
- shell startup files like `~/.zprofile` and `~/.zshrc`
- user-installed tools from Homebrew

This repo exists to document and automate that environment in a reviewable way.

## Baseline assumptions

- Host OS: macOS on Apple silicon
- Shell: `zsh`
- Projects root: `~/Projects`
- Homebrew prefix: `/opt/homebrew`

## Machine-level prerequisites

### Xcode Command Line Tools

```bash
xcode-select --install
```

### Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Core CLI tools

Install:

- `ansible`
- `direnv`
- `uv`
- `pyenv`
- `pyenv-virtualenv`
- `pre-commit`
- `gettext`
- `tree`
- `gh`
- `opencode`

```bash
brew install ansible direnv uv pyenv pyenv-virtualenv pre-commit gettext tree gh opencode
```

### GUI and larger tooling

Install:

- `codex`
- `docker-desktop`
- `virtualbox`

```bash
brew install --cask codex docker-desktop virtualbox
brew tap hashicorp/tap
brew install hashicorp/tap/hashicorp-vagrant
```

## Shell configuration

### Homebrew

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
```

### direnv

```bash
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
```

### pyenv

```bash
cat <<'EOF' >> ~/.zshrc
export PYENV_ROOT="$HOME/.pyenv"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
  eval "$(pyenv virtualenv-init -)"
fi
EOF
```

### gettext / envsubst

```bash
echo 'export PATH="/opt/homebrew/opt/gettext/bin:$PATH"' >> ~/.zshrc
```

## Python strategy

Prefer `uv` and `pyenv` over shell aliases like `python=python3`.

Recommended baseline:

```bash
uv python install 3.12
pyenv install 3.12.2
```

## SSH

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub
```

## AI coding tools

### Codex

- install via Homebrew cask
- keep user-scoped config under `~/.codex`
- use repo-local `.envrc` only when intentionally simulating or overriding `CODEX_HOME`

### OpenCode

- install via Homebrew formula
- keep user-scoped config under `~/.config/opencode`
- use repo-local wrappers only when intentionally simulating XDG state in a project

## Example repo-specific bootstrap

### `safe`

```bash
cd ~/Projects/safe
direnv allow
pre-commit install
```

### `mlx-test`

```bash
cd ~/Projects/mlx-test
direnv allow
uv sync
python -c "import mlx.core as mx; print(mx.array([1, 2, 3]))"
mlx-smoke-test
mlx-code-smoke-test
```

### `socialpredict`

Requirements:

- Docker Desktop
- `gettext` for `envsubst`

Bootstrap:

```bash
cd ~/Projects/socialpredict
mkdir -p data/postgres data/certbot
chown -R "$(whoami)":staff data
./SocialPredict install
./SocialPredict up
```

## Vagrant

Vagrant is a required part of the layered automation setup, not an optional extra. The intended stack is:

- macOS host
- Vagrant VM
- Docker inside the VM
- automated coding inside containers running against isolated forks

```bash
brew install --cask virtualbox
brew tap hashicorp/tap
brew install hashicorp/tap/hashicorp-vagrant
```

On Apple silicon, provider and box compatibility still needs to be chosen deliberately per project. Do not assume an old `ubuntu/noble64` VirtualBox box will work unchanged on every Mac.

The current `safe` scaffold defaults to:

- provider: `virtualbox`
- box: `hashicorp-education/ubuntu-24-04`
- version: `0.1.0`

If VirtualBox on Apple silicon fails to boot, HashiCorp’s docs note this workaround:

```bash
VBoxManage setextradata global "VBoxInternal/Devices/pcbios/0/Config/DebugLevel"
```

## Ansible

Ansible is also a required host dependency. The intended pattern is:

- the macOS host runs Ansible
- Ansible provisions the Vagrant guest
- the guest installs and manages Docker
- coding workloads run inside Docker rather than directly on the host or directly on the VM

```bash
brew install ansible
```

## One-shot installer

```bash
cd ~/Projects/machinesetup
bash MACOS/install.sh
```

Optional environment flags:

- `INSTALL_DOCKER=0`
- `INSTALL_CODEX=0`
- `PYTHON_VERSION=3.12`

## Verification checklist

- `brew --version`
- `direnv version`
- `uv --version`
- `pyenv --version`
- `pre-commit --version`
- `opencode --version`
- `ansible --version`
- `codex --version`
- `docker --version`
- `docker compose version`
- `VBoxManage --version`
- `vagrant --version`
