let
  project_name = "Rust demo project.";
  description = "Rust project.";
  author = "reun";
  # Used for hyprctl window rules
  window_title = "My app";
in {
  description = description;
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "x86_64-darwin" ];
      perSystem = { config, lib, system, ... }:
        let
          projectRoot = builtins.toString ./.;
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ inputs.rust-overlay.overlays.default ];
          };

          rustTools =
            (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml);
          buildPackages = with pkgs;
            [ pkg-config clang cmake python3 cargo-watch rustTools ] ++
            # vulkan
            [
              # required by gmp-mpfr-sys build system
              gnum4
              glslang
              glslls
              shaderc # GLSL to SPIRV compiler - glslc
              shaderc.bin
              shaderc.static
              shaderc.dev
              shaderc.lib
              vulkan-headers
              vulkan-loader
              vulkan-validation-layers
              vulkan-tools # vulkaninfo
              renderdoc # Graphics debugger
              tracy # Graphics profiler
              vulkan-tools-lunarg # vkconfig
              libgcc

              # qt5Full # required for renderdoc
            ] ++ (lib.optional pkgs.stdenv.isLinux pkgs.linuxPackages.perf);
          # build and runtime dependencies 
          buildAndRunPackages = with pkgs; [ stdenv.cc.cc.lib ];
          # runtime packages
          runPackages = with pkgs; [
            xorg.libXcursor
            xorg.libXrandr
            xorg.libXi
            wayland
            wayland-protocols
            wayland-utils
            libxkbcommon
            hotspot
          ];
          # Define environment variables once
          envVars = {
            CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER =
              lib.optional pkgs.stdenv.isLinux "${pkgs.clang}/bin/clang";
            RUST_SRC_PATH = "${rustTools}/lib/rustlib/src/rust/library";
            LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
            RUSTFLAGS = "-C link-arg=-Wl,-rpath=${pkgs.renderdoc}/lib";
            LD_LIBRARY_PATH = with pkgs;
              lib.makeLibraryPath [
                stdenv.cc.cc.lib
                vulkan-loader
                vulkan-validation-layers
                wayland
                libxkbcommon
                shaderc.lib
              ] + ":/run/current-system/sw/lib";
            VULKAN_SDK = "${pkgs.vulkan-headers}";
            VK_LAYER_PATH =
              "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";
            VULKAN_LIB_DIR = "${pkgs.shaderc.lib}/lib";
            SHADERC_LIB_DIR = "${pkgs.shaderc.static}/lib";
            RUST_BACKTRACE = "full";
          };
          xdg_setup_hook = ''
            # Resolve XDG paths or use defaults
            _CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
            _DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"

            # Define full target paths on the system
            TARGET_CONFIG_DIR="$_CONFIG_HOME/${author}/${project_name}"
            TARGET_DATA_DIR="$_DATA_HOME/${author}/${project_name}"

            # 1. Ensure target system directories exist
            mkdir -p "$TARGET_CONFIG_DIR"
            mkdir -p "$TARGET_DATA_DIR"

            # 2. Create symlinks in the working directory pointing TO the system dirs
            # -s: symbolic, -f: force (overwrite), -n: treat link to dir as a file name
            ln -sfn "$TARGET_CONFIG_DIR" config_ln
            ln -sfn "$TARGET_DATA_DIR" share_ln

            echo "Local symlinks updated:"
            echo "   ./config_ln -> $TARGET_CONFIG_DIR"
            echo "   ./share_ln  -> $TARGET_DATA_DIR"

            # Auto-update .gitignore for the symlinks
            if [ -f .gitignore ]; then
              for link in "config_ln" "share_ln"; do
                if ! grep -q "^$link$" .gitignore; then
                  echo "$link" >> .gitignore
                  echo "📝 Added $link to .gitignore"
                fi
              done
            fi
          '';

          hypr_setting = ''
            # Check if we are currently inside a Hyprland session
            if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
                echo "Hyprland session detected. Applying window rules..."
                hyprctl keyword windowrule 'float, title:^(Carver Toy)$'
                # Ensure Wayland display is set correctly if not inherited
                export WAYLAND_DISPLAY=''${WAYLAND_DISPLAY:-wayland-1}
            fi
          '';

          shared_shell_hook = xdg_setup_hook + hypr_setting;
        in {
          devShells.default = pkgs.mkShell rec {
            nativeBuildInputs = buildPackages;
            buildInputs = buildAndRunPackages;
            packages = runPackages;
            shellHook = ''
              export PATH="$PATH:${
                lib.makeBinPath
                (buildPackages ++ buildAndRunPackages ++ runPackages)
              }"
            '' + shared_shell_hook;
            inherit (envVars)
              CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER RUST_SRC_PATH
              LIBCLANG_PATH LD_LIBRARY_PATH VULKAN_SDK VK_LAYER_PATH
              VULKAN_LIB_DIR SHADERC_LIB_DIR RUST_BACKTRACE;
          };
        };
    };
}
