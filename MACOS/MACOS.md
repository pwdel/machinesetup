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
- `multipass`
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
brew install ansible multipass direnv uv pyenv pyenv-virtualenv pre-commit gettext tree gh opencode
```

### GUI and larger tooling

Install:

- `codex`
- `docker-desktop`

```bash
brew install --cask codex docker-desktop
```

## Shell configuration

Sample source-of-truth files for the macOS shell setup live here:

- `MACOS/templates/zprofile.example`
- `MACOS/templates/zshrc.example`

### Homebrew

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
```

If you still use `bash`, add the same shellenv there too:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bashrc
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

If you still use `bash`, add the same path there too:

```bash
echo 'export PATH="/opt/homebrew/opt/gettext/bin:$PATH"' >> ~/.bashrc
```

### Ansible and Multipass shell helpers

These tools do not need custom environment variables, but they benefit from a few stable aliases for the `safe` workflow:

```bash
cat <<'EOF' >> ~/.zshrc
# safe-vm-tools
alias mp='multipass'
alias ap='ansible-playbook'
alias safe-bootstrap='bash "$HOME/Projects/safe/infra/scripts/bootstrap_mac.sh"'
alias safe-vm='bash "$HOME/Projects/safe/infra/scripts/mp-shell.sh"'
EOF
```

If you still use `bash`, add the same block to `~/.bashrc`.

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
pre-commit install
bash infra/scripts/bootstrap_mac.sh
```

Notes:

- `direnv allow` is optional for the VM bootstrap path
- `safe` expects a local SSH keypair such as `~/.ssh/id_ed25519` and seeds `~/.ssh/id_ed25519.pub` into the guest so Ansible can connect

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

## Multipass

Multipass is the recommended VM layer for the `safe` automation stack on macOS Apple silicon. The intended stack is:

- macOS host
- Multipass VM
- Docker inside the VM
- automated coding inside containers running against isolated forks

```bash
brew install multipass
```

Vagrant still belongs in the broader machine setup toolbox, but it is not the recommended `safe` implementation on Apple silicon.

## Ansible

Ansible is also a required host dependency. The intended pattern is:

- the macOS host runs Ansible
- Ansible provisions the Multipass guest
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
- `multipass version`
