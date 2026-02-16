{
  description = "My collection of project templates";

  outputs = { self }: {
    templates = {
      rust-graphics = {

        path = ./rust-graphics;
        description = "A Rust project template for graphics programming";
        welcomeText = ''
          A Rust project environment.
          Use cargo.

        '';
      };

      cpp = {
        path = ./cpp;
        description = "A C++ project template with CMake and Google Test";
        welcomeText = ''
          A C++ project environment, with CMake, vcpkg and Google Test.
          Use `just` to quickstart your development.
        '';
      };
    };

  };
}
