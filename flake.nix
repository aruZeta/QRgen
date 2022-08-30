{
  description = "Flake with nim 1.6.6 containing dochack and tools";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nixpkgs-nim-1-6-6.url = "nixpkgs/4fc665856d5a6be6f647fd9d63d9390f48763192";
  };

  outputs = { self, nixpkgs, nixpkgs-nim-1-6-6 }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      nim-unwrapped-1-6-6 =
        nixpkgs-nim-1-6-6.legacyPackages.${system}.nim-unwrapped.overrideAttrs
          (import ./nix/nim-dochack.nix);
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          nim-unwrapped-1-6-6
          nixpkgs-nim-1-6-6.legacyPackages.${system}.nim
        ];
      };
    };
}
