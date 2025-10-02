{
  description = "Brad's Sketchbook";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # Manually install nim packages
    # NOTE: I sadly couldn't get Nimble to work with Nix flakes yet
    nimja-pkg = {
      url = "github:enthus1ast/nimja";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, nimja-pkg }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "sketchbook";
          version = "0.0.1";
          src = ./.;

          buildInputs = with pkgs; [ nim-2_0 ];

          buildPhase = ''
            mkdir -p $out/bin

            # Manually install nim packages
            # NOTE: I sadly couldn't get Nimble to work with Nix flakes yet
            mkdir -p src/pkgs

            mkdir -p src/pkgs/nimja
            cp -r ${nimja-pkg}/src/* src/pkgs/nimja

            export HOME=$(pwd)
            ${pkgs.nim-2_0}/bin/nim c -d:release -o:$out/bin/app src/sketchbook.nim
          '';
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ nim-2_0 ];
          shellHook = ''
            echo "Nimrod: $(${pkgs.nim-2_0}/bin/nim -v)"
            echo "Run './result/bin/app'."
          '';
        };
      });
}
