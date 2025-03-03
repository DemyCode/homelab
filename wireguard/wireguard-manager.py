import json
import subprocess
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

WG_INTERFACE = "wg0"
PEERS_FILE = "/etc/wireguard/peers.json"

app = FastAPI()

class Peer(BaseModel):
    public_key: str
    allowed_ip: str
    endpoint: str

def load_peers():
    try:
        with open(PEERS_FILE, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        return []

def save_peers(peers):
    with open(PEERS_FILE, "w") as f:
        json.dump(peers, f, indent=4)

def add_peer(public_key: str, allowed_ip: str, endpoint: str):
    peers = load_peers()

    for peer in peers:
        if peer["public_key"] == public_key:
            return {"status": "error", "message": "Peer already exists"}

    new_peer = {"public_key": public_key, "allowed_ip": allowed_ip, "endpoint": endpoint}
    peers.append(new_peer)
    save_peers(peers)

    subprocess.run(["wg", "set", WG_INTERFACE, "peer", public_key, "allowed-ips", allowed_ip])

    return {"status": "success", "message": "Peer added", "peer": new_peer}

@app.post("/add_peer")
async def add_peer_endpoint(peer: Peer):
    try:
        response = add_peer(peer.public_key, peer.allowed_ip, peer.endpoint)
        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5000)
