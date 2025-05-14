{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      inputs.nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import inputs.nixpkgs {inherit system;};
        });

    scriptDrvs = forEachSupportedSystem ({pkgs}: let
      getSystem = "SYSTEM=$(nix eval --impure --raw --expr 'builtins.currentSystem')";
      forEachDir = exec: ''
        for dir in */; do
          (
            cd "''${dir}"

            ${exec}
          )
        done
      '';
    in {
      build = pkgs.writeShellApplication {
        name = "build";
        text = ''
          ${getSystem}

          ${forEachDir ''
            echo "building ''${dir}"
            nix build ".#devShells.''${SYSTEM}.default"
          ''}
        '';
      };

      check = pkgs.writeShellApplication {
        name = "check";
        text = forEachDir ''
          echo "checking ''${dir}"
          nix flake check --all-systems --no-build
        '';
      };

      update = pkgs.writeShellApplication {
        name = "update";
        text = forEachDir ''
          echo "updating ''${dir}"
          nix flake update
        '';
      };
    });
  in {
    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        packages = with scriptDrvs.${pkgs.system}; [
          build
          check
          update
        ];
      };
    });

    templates = {
      rust = {
        path = ./rust;
        description = "Rust development environment";
      };

      go = {
        path = ./go;
        description = "Go development environment";
      };

      zig = {
        path = ./zig;
        description = "Zig development environment";
      };

      shell = {
        path = ./shell;
        description = "Shell development environment";
      };

      node = {
        path = ./node;
        description = "Node development environment";
      };
    };
  };
}
