# machinesetup

Portable, versioned machine setup for macOS and Linux.

This repo is meant to document and automate a user-scoped development environment, especially for AI-assisted coding. It is intentionally kept in git so setup changes can be reviewed, shared, and reused.

## Start here

- macOS: read [MACOS/MACOS.md](/Users/patrick/Documents/Projects/machinesetup/MACOS/MACOS.md) and run `bash MACOS/install.sh`
- Linux: read [LINUX/LINUX.md](/Users/patrick/Documents/Projects/machinesetup/LINUX/LINUX.md) and run `bash LINUX/install.sh`

## Scope

- Homebrew bootstrap
- shared CLI baseline including GitHub CLI (`gh`)
- shell setup for `zsh`
- Python tooling via `uv` and `pyenv`
- AI coding tools like Codex and OpenCode
- Docker Desktop or Docker Engine for local containerized projects
- optional Vagrant for isolated VM-based automation work

## Notes

- macOS targets Apple silicon
- Linux currently targets Ubuntu and Debian
- The installer is intentionally conservative and uses environment flags for optional tools
