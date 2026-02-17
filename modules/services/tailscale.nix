# tailscale.nix
{ config, lib, pkgs, ... }:

{
  services.tailscale.enable = true;

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
  }; 

  system.stateVersion = "25.11"; 
}
