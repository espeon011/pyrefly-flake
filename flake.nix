{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {inherit system overlays;};

        rustPlatform = pkgs.makeRustPlatform {
          cargo = pkgs.rust-bin.stable.latest.minimal;
          rustc = pkgs.rust-bin.stable.latest.minimal;
        };

        pyrefly = rustPlatform.buildRustPackage (finalAttrs: {
          pname = "pyrefly";
          version = "0.33.0";

          src = pkgs.fetchFromGitHub {
            owner = "facebook";
            repo = "pyrefly";
            tag = finalAttrs.version;
            hash = "sha256-sI+F+kI8ApE1cHpE3q/tSntaD/1c26jT5BLJ3BtzpBA=";
          };

          buildAndTestSubdir = "pyrefly";
          cargoHash = "sha256-+93SQA0KrJsskXUMA9S5eaq0EIWVK1/ZoUbp6wQ7Cc4=";

          nativeInstallCheckInputs = [pkgs.versionCheckHook];
          doInstallCheck = true;

          # requires unstable rust features
          env.RUSTC_BOOTSTRAP = 1;

          # passthru.updateScript = nix-update-script {};

          meta = {
            description = "Fast type checker and IDE for Python";
            homepage = "https://github.com/facebook/pyrefly";
            license = pkgs.lib.licenses.mit;
            mainProgram = "pyrefly";
            platforms = pkgs.lib.platforms.linux ++ pkgs.lib.platforms.darwin;
            maintainers = with pkgs.lib.maintainers; [
              cybardev
              QuiNzX
            ];
          };
        });
      in {
        packages = {
          inherit pyrefly;
          default = pyrefly;
        };
      }
    );
}
