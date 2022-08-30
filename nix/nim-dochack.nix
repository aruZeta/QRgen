final: prev: {
  nim-unwrapped = prev.nim-unwrapped.overrideAttrs (old: {
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
}
