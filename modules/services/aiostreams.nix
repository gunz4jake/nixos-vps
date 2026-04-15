# ./modules/services/aiostreams.nix
{ config, pkgs, ... }:

{
  # --- 1. OCI Container ---
  virtualisation.oci-containers.containers.aiostreams = {
    image = "ghcr.io/viren070/aiostreams:latest";
    autoStart = true;

    ports = [ "127.0.0.1:3000:3000" ];

    volumes = [ "/var/lib/aiostreams/data:/app/data" ];

    environment = {
      BASE_URL = "https://aiostreams.ningen.xyz";
    };

    # Secret env file must contain: SECRET_KEY=<64-char hex>
    # Generate with: openssl rand -hex 32
    environmentFiles = [ config.sops.secrets."aiostreams_env".path ];
  };

  # Ensure data directory exists with correct ownership
  systemd.tmpfiles.rules = [
    "d /var/lib/aiostreams/data 0750 root root -"
  ];

  # --- 2. SOPS Secret ---
  sops.secrets."aiostreams_env" = {};

  # --- 3. Nginx Reverse Proxy ---
  services.nginx.virtualHosts."aiostreams.ningen.xyz" = {
    enableACME = true;
    forceSSL = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:3000";
      proxyWebsockets = true;
    };
  };
}
