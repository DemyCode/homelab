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

            pkgs.wasm-bindgen-cli
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
          pkgs.wasm-bindgen-cli
        ];
        buildPhase = ''
          export RUSTUP_HOME=$out/.rustup
          export CARGO_HOME=$out/.cargo
          rustup show
          trunk build --release --offline
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp -r $src/* $out/bin/
        '';
      };
    };
}
