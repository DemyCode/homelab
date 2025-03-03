{ config, pkgs, lib, ... }:

let
  wgInterface = "wg0";
  wireguardManagerScript = pkgs.writeTextFile {
    name = "wireguard_manager.py";
    text = builtins.readFile ./wireguard_manager.py;
  };
in
{
  services.wireguard-manager = {
    enable = true;
  };

  systemd.services.wireguard-manager = {
    description = "WireGuard Peer Manager API";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 ${wireguardManagerScript}";
      WorkingDirectory = "/etc/wireguard";
      Restart = "always";
      User = "root";
    };
  };
  
  environment.systemPackages = with pkgs; [ python312Full python312Packages.fastapi python312Packages.pydantic ];
}
