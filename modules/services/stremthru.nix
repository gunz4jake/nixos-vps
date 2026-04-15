# ./modules/services/stremthru.nix
{ config, pkgs, ... }:

{
  # --- 1. OCI Container ---
  virtualisation.oci-containers.containers.stremthru = {
    image = "docker.io/muniftanjim/stremthru:latest";
    autoStart = true;

    ports = [ "127.0.0.1:8080:8080" ];

    volumes = [ "/var/lib/stremthru/data:/app/data" ];

    environment = {
      STREMTHRU_BASE_URL = "https://stremthru.ningen.xyz";
    };

    # Secret env file must contain: STREMTHRU_AUTH=username:password
    environmentFiles = [ config.sops.secrets."stremthru_env".path ];
  };

  # Ensure data directory exists with correct ownership
  systemd.tmpfiles.rules = [
    "d /var/lib/stremthru/data 0750 root root -"
  ];

  # --- 2. SOPS Secret ---
  sops.secrets."stremthru_env" = {};

  # --- 3. Nginx Reverse Proxy ---
  services.nginx.virtualHosts."stremthru.ningen.xyz" = {
    enableACME = true;
    forceSSL = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:8080";
      proxyWebsockets = true;
    };
  };
}
