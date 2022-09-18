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
      nim-1-6-6 = ( import nixpkgs-nim-1-6-6 {
        inherit system;
        overlays = [ ( final: prev: {
          nim-unwrapped = prev.nim-unwrapped.overrideAttrs (old: {
            buildPhase = old.buildPhase + ''
              ./bin/nim js $kochArgs tools/dochack/dochack.nim
            ''; # added dockhack.js
            installPhase = old.installPhase + ''
              cp -r tools $out/nim
            ''; # added tools folder
          });
        })];
      }).nim;
    in {
      packages.${system}.default = nim-1-6-6;
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          nim-1-6-6
          # For emacs
          pkgs.nimlsp
        ];
      };
    };
}
