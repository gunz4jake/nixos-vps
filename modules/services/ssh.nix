# ssh.nix
{ config, lib, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "yes";
    };
  };

  services.fail2ban = {
    enable = true;
    bantime = "24h";
    maxretry = 5;
  };

  system.stateVersion = "25.11"; 
}
