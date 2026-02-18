# ./modules/services/synapse.nix
{ config, pkgs, ... }:

{
  # --- 1. PostgreSQL Database ---
  services.postgresql = {
    enable = true;
    initdbArgs = [ "--locale=C" "--encoding=UTF8" ];
    ensureDatabases = [ "matrix-synapse" ];
    ensureUsers = [
      {
        name = "matrix-synapse";
        ensureDBOwnership = true;
      }
    ];
  };

  # --- 2. Synapse Service ---
  services.matrix-synapse = {
    enable = true;

    settings = {
      server_name = "ningen.xyz";
      public_baseurl = "https://matrix.ningen.xyz";

      database = {
        name = "psycopg2";
        args = {
          user = "matrix-synapse";
          database = "matrix-synapse";
          host = "/run/postgresql";
        };
      };

      media_retention = {
        local_media_lifetime = "90d";
        remote_media_lifetime = "30d";
        unused_expiration_time = "1d";
      };
      # Tell Matrix clients to use your Coturn server
      turn_uris = [
        "turn:matrix.ningen.xyz:3478?transport=udp"
        "turn:matrix.ningen.xyz:3478?transport=tcp"
      ];
      # How long a client's TURN authorization lasts (1 day in milliseconds)
      turn_user_lifetime = 86400000;

      listeners = [
        {
          port = 8008;
          bind_addresses = [ "::1" "127.0.0.1" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [ "client" "federation" ];
              compress = false;
            }
          ];
        }
      ];
    };

    extraConfigFiles = [
      config.sops.secrets."synapse_secrets".path
    ];
  };

  systemd.services.matrix-synapse.requires = [ "postgresql.service" ];
  systemd.services.matrix-synapse.after = [ "postgresql.service" ];

  # --- 3. Coturn (TURN/STUN Server) ---
  services.coturn = {
    enable = true;
    use-auth-secret = true;
    static-auth-secret-file = config.sops.secrets."turn_secret".path;
    realm = "matrix.ningen.xyz";
    listening-port = 3478;
  };

  # --- 4. SOPS Secrets ---
  sops.secrets."synapse_secrets" = {
    owner = "matrix-synapse";
    group = "matrix-synapse";
  };

  sops.secrets."turn_secret" = {
    owner = "turnserver";
    group = "turnserver";
  };

  # --- 5. Nginx Virtual Hosts ---
  services.nginx.virtualHosts = {
    "ningen.xyz" = {
      enableACME = true;
      forceSSL = true;

      locations."= /.well-known/matrix/server".extraConfig = ''
        add_header Content-Type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '{"m.server": "matrix.ningen.xyz:443"}';
      '';

      locations."= /.well-known/matrix/client".extraConfig = ''
        add_header Content-Type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '{"m.homeserver": {"base_url": "https://matrix.ningen.xyz"}}';
      '';
    };

    "matrix.ningen.xyz" = {
      enableACME = true;
      forceSSL = true;

      locations."/".proxyPass = "http://[::1]:8008";
      locations."/_matrix".proxyPass = "http://[::1]:8008";
      locations."/_synapse/client".proxyPass = "http://[::1]:8008";
    };
  };
}
