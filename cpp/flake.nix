{
  description = "Modern C++ Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        llvm = pkgs.llvmPackages;
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            # Toolchain
            llvm.clang
            llvm.lldb
            cmake
            ninja

            # Tooling
            just
            llvm.clang-tools # LSP
            cppcheck # Linter
            gtest # Google Test

            # Package Management
            vcpkg
            pkg-config
          ];

          shellHook = ''
            export VCPKG_ROOT=${pkgs.vcpkg}/share/vcpkg
            echo "C++ Environment Loaded"
            clang --version
            vcpkg --version
            cmake --version
          '';
        };
      });
}
