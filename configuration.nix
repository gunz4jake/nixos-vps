{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Networking
      ./modules/networking/dns.nix
      ./modules/networking/firewall.nix
      ./modules/networking/tailscale.nix

      # Security
      ./modules/security/ssh.nix

      # Web (shared nginx base + ACME)
      ./modules/web/nginx.nix

      # Services
      ./modules/services/synapse.nix
      ./modules/services/uptime-kuma.nix
      ./modules/services/aiostreams.nix
      ./modules/services/stremthru.nix
      ./modules/services/jellyfin.nix
    ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  nixpkgs.config.allowUnfree = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;

    # Reduce dirty page writeback pressure on VDS storage
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 5;

    # Network throughput tuning (beneficial for Matrix federation)
    "net.core.somaxconn" = 1024;
    "net.ipv4.tcp_fastopen" = 3;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "Sun 03:00"; # Explicit time to avoid random I/O spikes
    options = "--delete-older-than 14d";
  };
  nix.optimise = {
    automatic = true;
    dates = [ "Sun 04:00" ]; # 1 hour after GC to avoid simultaneous I/O
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  networking.hostName = "nixos-vps"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # zramswap - Priority 100 (higher than disk swap)
  zramSwap = {
    enable = true;
    priority = 100;
    algorithm = "zstd";
  };

  # Disk Swap - Fallback if ZRAM fills up
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 2048; # 2GB
    priority = 0;
  } ];

  # Set your time zone.
  time.timeZone = "UTC";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
  #   font = "Lat2-Terminus16";
    keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  };

  security.sudo.wheelNeedsPassword = false;

  users.users.jacob = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0nIAS13sZxmF4DKSij+IFftPFLEG20wPNbn9msP+cx"
    ];
  #  packages = with pkgs; [
  #    tree
  #  ];
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    htop
    tmux
    claude-code
  ];

  networking.firewall.enable = true;

  system.stateVersion = "25.11"; # Did you read the comment?

}

