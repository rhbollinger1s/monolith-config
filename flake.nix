{
  description = "flake for Monolith";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-stable;

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations."Monolith" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
        ];
    };
  };

}
