{
  description = "Flake configuration for nixos-vps";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix, ... }@inputs: {
    
    nixosConfigurations = {
      "nixos-vps" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        
        specialArgs = { inherit inputs; };
        
        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
