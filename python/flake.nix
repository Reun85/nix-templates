{
  description = "Python demo";
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { config, lib, system, ... }:
        let
          pkgs = import inputs.nixpkgs { inherit system; };

          pythonEnv = pkgs.python3.withPackages (ps:
            with ps; [
              requests
              beautifulsoup4
              lxml
              pip
              # Add other runtime deps here
            ]);

          buildAndToolPackages = with pkgs; [ pkg-config pythonEnv ];

          runtimeLibs = with pkgs; [ stdenv.cc.cc.lib libxkbcommon ];

        in {
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = buildAndToolPackages;

            buildInputs = runtimeLibs;

            shellHook = ''
              export LD_LIBRARY_PATH="${
                lib.makeLibraryPath runtimeLibs
              }:$LD_LIBRARY_PATH"
              echo "Python environment loaded."
            '';
          };
        };
    };
}
