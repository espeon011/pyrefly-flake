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
          version = "0.41.2";

          src = pkgs.fetchFromGitHub {
            owner = "facebook";
            repo = "pyrefly";
            tag = finalAttrs.version;
            hash = "sha256-m4rj5isJBjVtog0J4SaWFKHSAeOVPQ3egPiLUpeuYYY=";
          };

          buildAndTestSubdir = "pyrefly";
          cargoHash = "sha256-muR/Wi4Kzi6GRoi0UTN4bPCH/MFMREIPANIPIcosLKo=";

          nativeInstallCheckInputs = [pkgs.versionCheckHook];
          doInstallCheck = true;
          checkFlags = [
            "--skip=test::lsp::lsp_interaction::configuration::test_pythonpath_change"
            "--skip=test::lsp::lsp_interaction::configuration::test_workspace_pythonpath_ignored_when_set_in_config_file"
            "--skip=test::lsp::lsp_interaction::notebook_definition::test_notebook_definition_import"
          ];

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
