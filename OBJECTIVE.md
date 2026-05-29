# Machinesetup Objective

This file tracks machine-level setup work that supports the `safe` automation environment.

## Current Direction

The machine setup layer should:

1. prepare a macOS control-plane machine
2. prepare apt-based Linux control-plane machines
3. install the tools needed to operate `safe`
4. keep the user-scoped shell setup and examples versioned
5. support future infrastructure tooling such as Terraform for DigitalOcean

## Checklist

- [x] Consolidate the macOS setup guidance into `MACOS/MACOS.md`
- [x] Add a macOS installer script
- [x] Install and document `ansible`
- [x] Install and document `multipass`
- [x] Add shell helper aliases for the `safe` workflow
- [x] Add sample `zprofile` and `zshrc` templates
- [x] Install and document Terraform and `doctl` on macOS for DigitalOcean infrastructure management
- [x] Install and document UUID generation helpers
- [x] Add apt-based Linux setup guidance and installer
- [x] Add API conformance CLI installs
- [ ] Document the final macOS control-plane workflow once the `safe` remote-host path is complete
