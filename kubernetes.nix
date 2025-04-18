{ config, pkgs, ... }:
let secrets = builtins.fromTOML (builtins.readFile ./secrets.toml);
in {

  # packages for administration tasks
  environment.systemPackages = with pkgs; [ kompose kubectl kubernetes ];
  services.kubernetes = {
    roles = [ "master" "node" ];
    kubelet.extraOpts = "--fail-swap-on=false";
    masterAddress = "192.168.1.5";
  };
  users.users.kubernetes = {
    description = "kubernetes";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs;
      map lib.lowPrio [
        (pkgs.wrapHelm pkgs.kubernetes-helm {
          plugins = with pkgs.kubernetes-helmPlugins; [
            helm-secrets
            helm-diff
            helm-s3
            helm-git
          ];
        })
        wireguard-mesh-coordinator.packages.x86_64-linux.default
        pkgs.curl
        pkgs.gitMinimal
        pkgs.just
        pkgs.nginx
        pkgs.wireguard-tools
      ];
    openssh.authorizedKeys.keys = [ secrets.kubernetes_ssh ];
  };
  networking.firewall.enable = false;
}
