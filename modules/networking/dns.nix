# ./modules/networking/dns.nix
{ config, lib, pkgs, ... }:

{
  # Use systemd-resolved with DNS-over-TLS via Quad9
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "149.112.112.112#dns.quad9.net" "2620:fe::9#dns.quad9.net" ];
    extraConfig = ''
      DNS=9.9.9.9#dns.quad9.net 2620:fe::fe#dns.quad9.net
      DNSOverTLS=yes
    '';
  };
}
