{
  description = "Brad's Sketchbook";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "sketchbook";
          version = "0.0.1";
          src = ./.;

          buildInputs = with pkgs; [ nim-2_0 nimble ];

          buildPhase = ''
            #export HOME=$(pwd)

            #${pkgs.nimble}/bin/nimble build
          '';

          installPhase = ''
            mkdir -p $out/bin
            cat > $out/bin/app <<EOF
            #!/usr/bin/env ${pkgs.bash}/bin/bash
            export HOME=$(pwd)
            ${pkgs.nimble}/bin/nimble run
            EOF
            chmod +x $out/bin/app
            #cp sketchbook $out/bin/app
          '';
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ nim-2_0 nimble ];
          shellHook = ''
            echo "Nimrod: $(${pkgs.nim-2_0}/bin/nim -v)"
            echo "Run './result/bin/app'."
          '';
        };
      });
}
