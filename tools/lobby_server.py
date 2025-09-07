from __future__ import annotations
import time
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

APP = FastAPI()
APP.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET","POST","OPTIONS"],
    allow_headers=["Authorization","Content-Type"],
)

@APP.get("/api/ping")
def api_ping():
    return {"ok": True, "ts": int(time.time())}
