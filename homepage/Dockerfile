# Nix builder
FROM nixos/nix:latest AS builder

# Copy our source and setup our working dir.
COPY . /tmp/build
WORKDIR /tmp/build

# Build our Nix environment
RUN nix \
  --extra-experimental-features "nix-command flakes" \
  --option filter-syscalls false \
  --print-build-logs \
  build

FROM nginx

COPY --from=builder /tmp/build/result /usr/share/nginx/html
