{
  description = "A Nix-flake-based Node.js development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs = inputs: let
    nodeVersion = 24;
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      inputs.nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [inputs.self.overlays.default];
          };
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {};
          };
        });
  in {
    overlays.default = final: prev: rec {
      nodejs = final."nodejs_${toString nodeVersion}";
      yarn = prev.yarn.override {inherit nodejs;};
    };

    devShells = forEachSupportedSystem ({
      pkgs,
      pre-commit-check,
    }: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          node2nix
          nodejs
          yarn
        ];

        shellHook = ''
          yarn install
          ${pre-commit-check.shellHook}
        '';
      };
    });
  };
}
