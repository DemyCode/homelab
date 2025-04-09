{ config, pkgs, ... }: {
  networking.extraHosts = "${config.networking.privateIPv4} api.kube";
  services.kubernetes = {
    easyCerts = true;
    addons.dashboard.enable = true;
    roles = [ "master" "node" ];
    apiserver = {
      securePort = 443;
      advertiseAddress = config.networking.privateIPv4;
    };
    masterAddress = "api.kube";
  };
  services.dockerRegistry.enable = true;
  environment.systemPackages = with pkgs; [ kompose kubectl vim ];
}
