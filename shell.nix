{ pkgs ? import <nixpkgs> {}
, ...
}:

let
  nim-1-6-6-pkgs = (import (builtins.fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/4fc665856d5a6be6f647fd9d63d9390f48763192.tar.gz";
    sha256 = "sha256:1ki0bfbwss244168r1apb3bkjx6w05bmjbpazwgq8298dp2ixx7y";
  }) { overlays = [
         ( self: super: {
           nim-unwrapped = super.nim-unwrapped.overrideAttrs (oldAttrs: {
             buildPhase = ''
               runHook preBuild
               local HOME=$TMPDIR
               ./bin/nim c koch
               ./koch boot $kochArgs --parallelBuild:$NIX_BUILD_CORES
               ./koch toolsNoExternal $kochArgs --parallelBuild:$NIX_BUILD_CORES
               ./bin/nim js $kochArgs tools/dochack/dochack.nim
               runHook postBuild
             ''; # added dockhack.js

             installPhase = ''
               runHook preInstall
               install -Dt $out/bin bin/*
               ln -sf $out/nim/bin/nim $out/bin/nim
               ./install.sh $out
               runHook postInstall
               cp -r tools $out/nim
             ''; # added tools folder
           });
         })
       ];
     }
  );
in pkgs.mkShell {
  buildInputs = with pkgs; [
    nim-1-6-6-pkgs.nim
  ];
}
