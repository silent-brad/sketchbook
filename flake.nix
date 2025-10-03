{
  description = "Brad's Sketchbook";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # Manually install nim packages
    #nimja-pkg = {
    #url = "github:enthus1ast/nimja";
    #flake = false;
    #};
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
            #mkdir -p src/nimja
            #cp -r $\{nimja-pkg}/src/nimja/* src/nimja

            cp -r ${nim-pkgs.packages.${system}.default}/src/* src/*

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
