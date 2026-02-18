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
    ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise = {
    automatic = true;
    dates = [ "06:00" ];
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  networking.hostName = "nixos-vps"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # zramswap
  zramSwap.enable = true;

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
  ];

  networking.firewall.enable = true;

  system.stateVersion = "25.11"; # Did you read the comment?

}

