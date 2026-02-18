# ./modules/security/ssh.nix
{ config, lib, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.fail2ban = {
    enable = true;
    bantime = "24h";
    maxretry = 5;
  };
}
