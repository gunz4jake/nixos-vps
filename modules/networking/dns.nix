# ./modules/networking/dns.nix
{ config, lib, pkgs, ... }:

{
  # Use systemd-resolved with DNS-over-TLS via Quad9
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "1.0.0.1#cloudflare-dns.com" "2606:4700:4700::1001#cloudflare-dns.com" ];
    extraConfig = ''
      DNS=1.1.1.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com
      DNSOverTLS=yes
    '';
  };
}
