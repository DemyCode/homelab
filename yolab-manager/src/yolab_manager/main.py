from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
from pathlib import Path

app = FastAPI()


@app.get("/update")
def health():
    git_repo_path = Path("/deployments")
    if git_repo_path.exists() and git_repo_path.is_dir():
        os.chdir(git_repo_path)
        os.system("git pull")
    else:
        os.system("git clone https://github.com/DemyCode/homelab /deployments")


def serve():
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8080)
