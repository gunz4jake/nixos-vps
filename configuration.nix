# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/services/ssh.nix
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

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  networking.hostName = "nixos-vps"; # Define your hostname.
  networking.nameservers = [ "9.9.9.9" "149.112.112.112" ];
  services.tailscale.enable = true;

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

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    wget
  ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  system.stateVersion = "25.11"; # Did you read the comment?

}

