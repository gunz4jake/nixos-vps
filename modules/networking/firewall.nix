# ./modules/networking/firewall.nix
{ config, lib, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [ 80 443 3478 ];
    allowedUDPPorts = [ 3478 ];
    # Coturn uses a wide range of UDP ports to temporarily route media traffic
    allowedUDPPortRanges = [ { from = 49152; to = 65535; } ];
  };
}
