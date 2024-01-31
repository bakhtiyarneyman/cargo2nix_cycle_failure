{
  inputs = {
    cargo2nix.url = "github:cargo2nix/cargo2nix/release-0.11.0";
    flake-utils.follows = "cargo2nix/flake-utils";
    nixpkgs.follows = "cargo2nix/nixpkgs";
  };

  outputs = inputs: with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ cargo2nix.overlays.default ];
        };

        rustPkgs = pkgs.rustBuilder.makePackageSet {
          rustVersion = "1.75.0";
          packageFun = import ./Cargo.nix;
        };

      in
      rec {
        packages = {
          cargo2nix_cycle_failure = (rustPkgs.workspace.cargo2nix_cycle_failure { });
          default = packages.cargo2nix_cycle_failure;
        };

        devShells.default = (rustPkgs.workspaceShell {
          packages = [
            pkgs.rust-analyzer
            pkgs.rustfmt
            inputs.cargo2nix.packages."${system}".cargo2nix
          ];
          # shellHook = ''
          #   export PS1="\033[0;31m☠dev-shell☠ $ \033[0m"
          # '';
        });

      }
    );
}
