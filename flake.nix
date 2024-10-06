{
  description = "A minimal flake for flawless, an execution engine for durable computation.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux"; # Adjust if you're targeting a different system
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.${system}.flawless = pkgs.stdenv.mkDerivation rec {
        pname = "flawless";
        version = "1.0.0-beta.1";

        dontUnpack = true;

        buildInputs = with pkgs; [
          stdenv.cc.cc
          openssl
          libgcc
          glibc
        ];

        nativeBuildInputs = [ pkgs.autoPatchelfHook ];

        src = pkgs.fetchurl {
          url = "https://downloads.flawless.dev/${version}/x64-linux/flawless";
          hash = "sha256-ZwFwXkB6azOIK68WmJD2Ihc3wIBa3Zk1k5CH3FfM7Rg=";
        };

        installPhase = ''
          mkdir -p $out/bin
          cp $src $out/bin/flawless
          chmod +x $out/bin/flawless
        '';

        postFixup = ''
          patchelf \
            --set-rpath ${pkgs.lib.makeLibraryPath [ pkgs.openssl pkgs.libgcc pkgs.glibc ]} \
            $out/bin/flawless
        '';

        meta = {
          description = "Flawless binary application";
          license = pkgs.lib.licenses.unfreeRedistributable;
        };
      };
    };
}
