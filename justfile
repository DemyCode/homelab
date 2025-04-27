remote-install HOST SSH_KEY:
    nix run github:nix-community/nixos-anywhere --extra-experimental-features 'nix-command flakes' -- --generate-hardware-config nixos-generate-config ./hardware-configuration.nix  --flake path:.#generic --target-host root@{{ HOST }} -i {{ SSH_KEY }} --build-on remote

remote-rebuild HOST SSH_KEY:
    nixos-rebuild switch --flake path:.#generic --target-host root@{{ HOST }} -i {{ SSH_KEY }}

local-rebuild:
    nixos-rebuild switch --flake path:.#generic

install-gitea:
    helm repo add gitea-charts https://dl.gitea.com/charts/
    helm repo update
    helm install gitea gitea-charts/gitea -f manifests/gitea-values.yaml

local-pvc:
    kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
    kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    kubectl get storageclass

