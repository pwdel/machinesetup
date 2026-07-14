# machinesetup

Portable, versioned machine setup for macOS and Linux.

This repo is meant to document and automate a user-scoped development environment, especially for AI-assisted coding. It is intentionally kept in git so setup changes can be reviewed, shared, and reused.

## Start here

- macOS: read [MACOS/MACOS.md](MACOS/MACOS.md) and run `bash MACOS/install.sh`
- Linux: read [LINUX/LINUX.md](LINUX/LINUX.md) and run `bash LINUX/install.sh`

## Default installed tooling

Both installers target the same core workflow and toolchain:

- Core CLI: `ansible`, `multipass`, `direnv`, `uv`, `go`, `node`, `pyenv`, `pyenv-virtualenv`, `pre-commit`, `gettext`, `tree`, `gh`, `trufflehog`, `terraform`, `doctl`, `ossp-uuid`, `k6`
- AI tooling: `opencode` and `codex`, both enabled by default
- API conformance tooling: `kin-openapi-validate` and `schemathesis`
- Python library baseline: `PyYAML` for `import yaml` in the baseline `pyenv` Python
- Container tooling: macOS installs `docker-desktop`; Linux installs Docker Engine with the Compose plugin
- UUID helper: both installers add a `new_uuid` shell function backed by `uuid -v 4`

Platform-specific install methods differ where they have to:

- macOS uses Homebrew formulas and casks
- Linux uses `apt` for bootstrap dependencies, Homebrew for most CLI tools, `snap` for `multipass`, and `npm` for `codex`

## Installer flags

- `PROJECTS_DIR=~/Projects` (default)
- `INSTALL_MULTIPASS=1` (Linux default)
- `INSTALL_OPENCODE=1` (default)
- `INSTALL_CODEX=1` (default)
- `INSTALL_DOCKER=1` (default)
- `PYTHON_VERSION=3.12` (default)
- `PYENV_INSTALL_VERSION=3.12.2` (default)

## Scope

- Homebrew bootstrap
- Linux `apt` bootstrap for build and system dependencies
- shell setup for `zsh` and optional `bash` compatibility
- Python tooling via `uv`, `pyenv`, and PyYAML
- AI coding tools like Codex and OpenCode
- Docker tooling for local containerized projects
- Multipass and Ansible for the `safe` VM workflow

## Notes

- This repo targets macOS on Apple silicon and apt-based Linux distros
- The installer is intentionally conservative and uses environment flags for optional tools
- Repo-specific examples under `~/Projects` are documented in the platform guides
