{
  description = "Latex development enviroment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-medium latexmk collection-latexextra fontawesome
            fontawesome5;
        };
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ texstudio tex pkgs.zathura just ];

          shellHook = ''echo "editor: texstudio"'';
        };
      });
}
