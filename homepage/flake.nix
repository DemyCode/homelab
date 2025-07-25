{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    {
      self,
      flake-utils,
      naersk,
      nixpkgs,
      rust-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
          overlays = [
            (import rust-overlay)
          ];
        };

        toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

        naersk' = pkgs.callPackage naersk {
          cargo = toolchain;
          rustc = toolchain;
        };
      in
      rec {
        # For `nix build` & `nix run`:
        defaultPackage = naersk'.buildPackage {
          src = ./.;
          copyTarget = true;
          compressTarget = false;
          postInstall = ''

          '';
        };

        # For `nix develop` (optional, can be skipped):
        devShell = pkgs.mkShell {
          packages = [
            pkgs.rustup
            pkgs.fish
          ];
          shellHook = ''
            rustup show
            fish
          '';
        };
      }
    );
}
