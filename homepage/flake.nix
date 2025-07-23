{
  description = "Hello world flake using uv2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      devShells.x86_64-linux = {
        default = pkgs.mkShell {
          packages = [
            pkgs.rustup
            pkgs.fish
            pkgs.trunk
            pkgs.leptosfmt
          ];
          shellHook = ''
            rustup show
            fish
          '';
        };
      };
      packages.x86_64-linux.default = pkgs.stdenv.mkDerivation {
        pname = "homepage";
        version = "1.0.0";
        src = ./.;
        buildInputs = [
          pkgs.rustup
          pkgs.trunk
        ];
        buildPhase = ''
          export RUSTUP_HOME=$out/.rustup
          export CARGO_HOME=$out/.cargo
          export RUSTUP_USE_CURL=1
          export RUSTUP_DIST_SERVER=https://static.rust-lang.org 
          rustup show
          trunk build --release
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp -r $src/* $out/bin/
        '';
      };
    };
}
