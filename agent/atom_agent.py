import os, time, json, pathlib, requests

ROOT = pathlib.Path.home() / ".atomnode"
CFG = ROOT / "config.json"
ROOT.mkdir(parents=True, exist_ok=True)

cfg = {
"api_base": os.getenv("ATOM_API_BASE", "http://144.202.23.216"),
"token": os.getenv("ATOM_TOKEN", "")
}

if CFG.exists():
try:
cfg.update(json.loads(CFG.read_text()))
except Exception:
pass
else:
CFG.write_text(json.dumps(cfg, indent=2))

def heartbeat():
headers = {}
if cfg.get("token"):
headers["Authorization"] = f"Bearer {cfg['token']}"
try:
r = requests.get(f"{cfg['api_base']}/api/ping", headers=headers, timeout=8)
return r.status_code, r.text[:200]
except Exception as e:
return 0, str(e)

if __name__ == "__main__":
print("[atom-agent] config:", cfg)
while True:
code, msg = heartbeat()
print(f"[atom-agent] ping -> {code} {msg}")
time.sleep(30)



