{
  description = "Flake configuration for nixos-vps";

  # Inputs define where your packages and modules come from.
  inputs = {
    # We are tracking the NixOS 25.11 stable branch. 
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Outputs define what this flake produces (a NixOS system in this case).
  outputs = { self, nixpkgs, sops-nix, ... }@inputs: {
    
    # "nixosConfigurations" is a standard Flake output for NixOS systems.
    nixosConfigurations = {
      # The key here ("nixos-vps") should exactly match your networking.hostName
      "nixos-vps" = nixpkgs.lib.nixosSystem {
        # Define the architecture of your VPS. 
        # (Change to "aarch64-linux" if you are on an ARM server)
        system = "x86_64-linux";
        
        # Pass our flake inputs to the module system so they can be accessed later
        specialArgs = { inherit inputs; };
        
        # This is where we pull in your existing configuration files
        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
