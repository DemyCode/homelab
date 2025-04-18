{ config, pkgs, wireguard-mesh-coordinator, ... }:
let secrets = builtins.fromTOML (builtins.readFile ./secrets.toml);
in {
  environment.systemPackages = with pkgs; [ kompose kubectl kubernetes ];
  services.kubernetes = {
    roles = [ "master" "node" ];
    kubelet.extraOpts = "--fail-swap-on=false";
    masterAddress = "192.168.1.5";
  };
  networking.firewall.enable = false;
}
