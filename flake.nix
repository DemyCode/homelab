{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.wireguard-mesh-coordinator.url =
    "github:DemyCode/wireguard-mesh-coordinator";

  outputs = { nixpkgs, disko, wireguard-mesh-coordinator, ... }: {
    # Use this for all other targets
    # nixos-anywhere --flake .#generic --generate-hardware-config nixos-generate-config ./hardware-configuration.nix <hostname>
    nixosConfigurations.generic = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        ./configuration.nix
        ./hardware-configuration.nix
        ./kubernetes-master.nix
        ./kubernetes-node.nix
      ];
      specialArgs = { inherit wireguard-mesh-coordinator; };
    };
    nixosConfigurations.network-machine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        ./configuration.nix
        ./hardware-configuration.nix
        ./kubernetes-master.nix
        ./kubernetes-node.nix
      ];
      specialArgs = { inherit wireguard-mesh-coordinator; };
    };
  };
}
