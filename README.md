# machinesetup

Portable, versioned machine setup for macOS.

This repo is meant to document and automate a user-scoped development environment, especially for AI-assisted coding. It is intentionally kept in git so setup changes can be reviewed, shared, and reused.

## Start here

- Read [MACOS/MACOS.md](/Users/patrick/Projects/machinesetup/MACOS/MACOS.md)
- Run `bash MACOS/install.sh`

## Scope

- Homebrew bootstrap
- shell setup for `zsh`
- Python tooling via `uv` and `pyenv`
- AI coding tools like Codex and OpenCode
- Docker Desktop for local containerized projects
- optional Vagrant for isolated VM-based automation work

## Notes

- This repo targets macOS on Apple silicon
- The installer is intentionally conservative and uses environment flags for optional tools
- Repo-specific examples under `~/Projects` are documented in the Mac guide
