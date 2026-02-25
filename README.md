# nixos-vps

A declarative NixOS configuration flake for my VPS environment.

## Overview

This repository contains the system setup, services, and secrets management for `nixos-vps` using Nix Flakes.

### Core Features

- **Reproducible**: Flake-based configuration tracking the `nixos-25.11` branch.
- **Secret Management**: Integrated `sops-nix` for managing encrypted secrets (`secrets.yaml`) using age/SSH keys.
- **Networking**: Built-in configurations for DNS, Firewall, and Tailscale VPN.
- **Web Layer**: Centralized Nginx routing with automated ACME (Let's Encrypt) TLS certificates.
- **Hosted Services**:
  - **Synapse**: Matrix homeserver for decentralized communication.
  - **Uptime Kuma**: Self-hosted monitoring dashboard.
- **System Optimizations**: Custom kernel `sysctl` settings tailored for VPS environments, plus `zramSwap` enabled with a fallback on-disk swap file to manage memory pressure efficiently.
- **Maintenance**: Automated weekly Nix garbage collection and store optimization.

## Directory Structure

- `flake.nix` & `flake.lock`: Entry point and dependency pins.
- `configuration.nix`: Main system configuration profile.
- `hardware-configuration.nix`: Hardware-specific configuration and filesystems.
- `secrets.yaml` & `.sops.yaml`: SOPS configuration and encrypted secrets file.
- `modules/`: Organized functional modules:
  - `networking/` (DNS, Firewall, Tailscale)
  - `security/` (SSH)
  - `services/` (Synapse, Uptime Kuma)
  - `web/` (Nginx, ACME)

## Deployment

To apply the configuration locally on the VPS:

```bash
sudo nixos-rebuild switch --flake .#nixos-vps
```

To deploy remotely from another machine (replace with the correct user and host):

```bash
nixos-rebuild switch --flake .#nixos-vps --target-host user@hostname --use-remote-sudo
```
