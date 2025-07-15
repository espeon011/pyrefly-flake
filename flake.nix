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
          version = "0.24.2";

          src = pkgs.fetchFromGitHub {
            owner = "facebook";
            repo = "pyrefly";
            tag = finalAttrs.version;
            hash = "sha256-h7N5O9b9R/2T5xrDC1iD/waAG6wGwgOiYQFpZ08oWRs=";
          };

          buildAndTestSubdir = "pyrefly";
          cargoHash = "sha256-/CClXkZU1YOQ1W5j8BuelZmL6ug+ipq7IYYqd4p0iQg=";

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
