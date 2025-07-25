# Nix builder
FROM nixos/nix:latest AS builder

WORKDIR /app
COPY . /app
RUN nix build path:.  --extra-experimental-features 'nix-command flakes' --no-link

CMD [ "nix", "run", "--extra-experimental-features", "nix-command flakes", "path:." ]
