{
  description = "enxg NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    tuxedo-nixos.url = "github:sund3RRR/tuxedo-nixos";
  };

  outputs = { self, nixpkgs, tuxedo-nixos, ... }@inputs: {
    nixosConfigurations.carbon = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        tuxedo-nixos.nixosModules.default
      ];
    };
  };
}
