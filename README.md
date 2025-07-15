# Nix flake package for pyrefly

This is a flake for the [pyrefly](https://github.com/facebook/pyrefly).

This package is provided as an alternative until this [PR](https://github.com/NixOS/nixpkgs/pull/417968) is merged.

## Usage

```nix
{
  description = "Your Python environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pyrefly-flake = {
      url = "github:espeon011/pyrefly-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pyrefly-flake,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        devShells.default = pkgs.mkShell {
          name = "my-python-project";
          packages = [
            pyrefly-flake.packages.${system}.default
          ];
        };
      }
    );
}
```

in your `flake.nix`, then run

```shell
nix develop
```
