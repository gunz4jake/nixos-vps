# ssh.nix
{ config, lib, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
    listenAddresses = [
      { addr = "100.76.38.93"; port = 22; }
    ];
  };

  services.fail2ban = {
    enable = true;
    bantime = "24h";
    maxretry = 5;
  };
}
