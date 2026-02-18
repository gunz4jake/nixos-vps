# ./modules/web/nginx.nix
{ config, lib, pkgs, ... }:

{
  # Shared ACME/Let's Encrypt defaults used by all virtual hosts
  security.acme = {
    acceptTerms = true;
    defaults.email = "jacob@ningen.xyz";
  };

  # Nginx base configuration with recommended settings
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };
}
