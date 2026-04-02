# machinesetup

Portable, versioned machine setup for macOS.

This repo is meant to document and automate a user-scoped development environment, especially for AI-assisted coding. It is intentionally kept in git so setup changes can be reviewed, shared, and reused.

## Start here

- Read [MACOS/MACOS.md](/Users/patrick/Projects/machinesetup/MACOS/MACOS.md)
- Run `bash MACOS/install.sh`

## Default installed tooling

The macOS installer installs these by default:

- Core CLI: `ansible`, `multipass`, `direnv`, `uv`, `pyenv`, `pyenv-virtualenv`, `pre-commit`, `gettext`, `tree`, `gh`, `trufflehog`, `terraform`, `doctl`
- AI tooling: `opencode` (formula) and `codex` (cask), both enabled by default
- Optional GUI tooling: `docker-desktop`, enabled by default

## Installer flags

- `PROJECTS_DIR=~/Projects` (default)
- `INSTALL_OPENCODE=1` (default)
- `INSTALL_CODEX=1` (default)
- `INSTALL_DOCKER=1` (default)
- `PYTHON_VERSION=3.12` (default)
- `PYENV_INSTALL_VERSION=3.12.2` (default)

## Scope

- Homebrew bootstrap
- shell setup for `zsh` and optional `bash` compatibility
- Python tooling via `uv` and `pyenv`
- AI coding tools like Codex and OpenCode
- Docker Desktop for local containerized projects
- Multipass and Ansible for the `safe` VM workflow

## Notes

- This repo targets macOS on Apple silicon
- The installer is intentionally conservative and uses environment flags for optional tools
- Repo-specific examples under `~/Projects` are documented in the Mac guide
