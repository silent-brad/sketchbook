{
  description = "Brad's Sketchbook";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nim-pkgs.url = "path:./nimpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, nim-pkgs }:
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
            for pkg in ${nim-pkgs.packages.${system}.default}/pkgs/*; do
              cp -r $pkg src/$(basename $pkg)
            done

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
