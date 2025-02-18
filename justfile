remote-install HOST SSH_KEY:
    nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./hardware-configuration.nix --impure --flake path:.#generic --target-host root@{{HOST}} -i {{SSH_KEY}}

remote-rebuild HOST SSH_KEY:
    nixos-rebuild switch --flake path:.#generic --target-host root@{{HOST}} -i {{SSH_KEY}}

local-rebuild:
    nixos-rebuild switch --flake path:.#generic
