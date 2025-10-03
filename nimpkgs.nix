{
  description = "Nim Packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # Add more packages here:
    nim-pkgs = [{
      name = "nimja";
      url = "github:enthus1ast/nimja";
      rev = "master";
      flake = false;
    }];
  };

  outputs = { self, nixpkgs, flake-utils, nim-pkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "nim-pkgs";
          version = "0.0.1";
          src = ./.;

          installPhase = ''
            mkdir -p $out/pkgs
            #cp -r $\{pkgs.nimja}/* $out/pkgs
            #mkdir -p src/nimja
            #cp -r $\{nimja-pkg}/src/nimja/* src/nimja
            ${map (pkg: ''
              mkdir -p $out/pkgs/${pkg.name}
              cp -r ${pkg}/src/${pkg.name}/* $out/pkgs/${pkg.name}
            '') nim-pkgs}
          '';
        };

        devShells.default = pkgs.mkShell {
          shellHook = ''
            echo "Installing Nim Packages"
          '';
        };
      });
}
