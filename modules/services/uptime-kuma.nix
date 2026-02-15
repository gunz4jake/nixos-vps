# ./modules/services/uptime-kuma.nix
{ config, pkgs, ... }:

{
  # --- 1. Uptime Kuma Service ---
  services.uptime-kuma = {
    enable = true;
    
    # Uptime Kuma is configured via environment variables passed into settings
    settings = {
      PORT = "3001";
      HOST = "127.0.0.1";
    };
  };

  # --- 2. Nginx Reverse Proxy ---
  # We are hooking into the Nginx service you already enabled in your synapse module
  services.nginx.virtualHosts."status.ningen.xyz" = {
    enableACME = true;
    forceSSL = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:3001";
      
      # IMPORTANT: Uptime Kuma requires WebSockets for its live-updating dashboard
      # This single line tells NixOS to inject the necessary Nginx Upgrade headers
      proxyWebsockets = true; 
    };
  };
}
