#!/bin/bash
set -e

KNOWN_PEER_IP="existing-peer-ip"
WG_INTERFACE="wg0"
USERNAME="root"

# Generate WireGuard keys
wg genkey | tee privatekey | wg pubkey > publickey
PRIVATE_KEY=$(cat privatekey)
PUBLIC_KEY=$(cat publickey)

# # Generate unique IP for this peer
# ALLOWED_IP="10.0.0.$(shuf -i 2-254 -n 1)/32"

# # Get public IP of the machine
# NEW_MACHINE_PUBLIC_IP=$(curl -4 ifconfig.me)

# # Send request to the WireGuard Manager
# JOIN_RESPONSE=$(curl -X POST "http://$KNOWN_PEER_IP:5000/add_peer" -H "Content-Type: application/json" -d '{
#     "public_key": "'"$PUBLIC_KEY"'",
#     "allowed_ip": "'"$ALLOWED_IP"'",
#     "endpoint": "'"$NEW_MACHINE_PUBLIC_IP:51820"'"
# }')

# echo "Server response: $JOIN_RESPONSE"

# # Fetch updated config
# scp "$USERNAME@$KNOWN_PEER_IP:/etc/wireguard/peers.json" /etc/wireguard/peers.json

# # Generate the final config
# NEW_CONFIG="/etc/wireguard/wg0.conf"

# cat <<EOF > "$NEW_CONFIG"
# [Interface]
# PrivateKey = $PRIVATE_KEY
# Address = $ALLOWED_IP
# ListenPort = 51820
# DNS = 1.1.1.1
# EOF

# jq -c '.[]' /etc/wireguard/peers.json | while read -r peer; do
#     PEER_PUBLIC_KEY=$(echo "$peer" | jq -r .public_key)
#     PEER_IP=$(echo "$peer" | jq -r .allowed_ip)
#     PEER_ENDPOINT=$(echo "$peer" | jq -r .endpoint)

#     if [[ "$PEER_IP" != "$ALLOWED_IP" ]]; then
#         echo "[Peer]" >> "$NEW_CONFIG"
#         echo "PublicKey = $PEER_PUBLIC_KEY" >> "$NEW_CONFIG"
#         echo "AllowedIPs = $PEER_IP" >> "$NEW_CONFIG"
#         echo "Endpoint = $PEER_ENDPOINT" >> "$NEW_CONFIG"
#     fi
# done

# # Enable WireGuard
# wg-quick up "$WG_INTERFACE"

# echo "Successfully joined WireGuard network!"

# Get public IPs of the machines

NEXT_IP=$(ssh "$USERNAME@$KNOWN_PEER_IP" "wg show wg0 allowed-ips | awk -F. '{print $4}' | awk -F/32 '{print $1}' | sort -n | tail -n 1")
NEXT_IP=$((NEXT_IP + 1))
ALLOWED_IP="10.0.0.$NEXT_IP/32"

ssh "$USERNAME@$KNOWN_PEER_IP" "wg set wg0 peer $PUBLIC_KEY allowed-ips $ALLOWED_IP"
NEW_MACHINE_PUBLIC_IP=$(curl -4 ifconfig.me)

