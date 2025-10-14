from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path
import subprocess

app = FastAPI()


@app.get("/update")
def health():
    git_repo_path = Path("/deployments")
    if git_repo_path.exists() and git_repo_path.is_dir():
        subprocess.Popen("git pull", cwd="/deployments", shell=True)
    else:
        subprocess.Popen(
            "git clone https://github.com/DemyCode/homelab /deployments", shell=True
        )
    if not Path("/deployments/hardware-configuration.nix").exists():
        subprocess.Popen("nixos-generate-config --no-filesystems --dir /deployments")


def serve():
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8080)
