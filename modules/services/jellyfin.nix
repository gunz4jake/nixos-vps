# ./modules/services/jellyfin.nix
{ config, pkgs, ... }:

{
  # --- 1. Jellyfin Service ---
  services.jellyfin = {
    enable = true;
    openFirewall = false; # We handle access via nginx
  };

  # --- 2. Nginx Reverse Proxy ---
  services.nginx.virtualHosts."jellyfin.ningen.xyz" = {
    enableACME = true;
    forceSSL = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:8096";
      proxyWebsockets = true;
    };
  };
}
