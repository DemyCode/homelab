remote-install HOST SSH_KEY:
    nix run github:nix-community/nixos-anywhere --extra-experimental-features 'nix-command flakes' -- --generate-hardware-config nixos-generate-config ./hardware-configuration.nix  --flake path:.#generic --target-host root@{{ HOST }} -i {{ SSH_KEY }} --build-on remote --disko-mode disko

remote-rebuild HOST SSH_KEY:
    nixos-rebuild switch --flake path:.#generic --target-host root@{{ HOST }} -i {{ SSH_KEY }}

local-rebuild:
    nixos-rebuild switch --flake path:.#generic

docker-update:
    docker compose config --lock-image-digests > docker-compose.lock
