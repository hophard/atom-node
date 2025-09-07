import os, sys, time, json, pathlib, requests, shutil, platform, uuid
ROOT = pathlib.Path.home() / ".atomnode"
CFG  = ROOT / "config.json"
NODE = ROOT / "node.json"
ROOT.mkdir(parents=True, exist_ok=True)
cfg = {"api_base": os.getenv("ATOM_API_BASE","http://144.202.23.216"),
       "token": os.getenv("ATOM_TOKEN",""),
       "update_url": os.getenv("ATOM_UPDATE_URL","https://raw.githubusercontent.com/hophard/atom-node/main/agent/atom_agent.py")}
if CFG.exists():
    try: cfg.update(json.loads(CFG.read_text()))
    except Exception: pass
else:
    CFG.write_text(json.dumps(cfg, indent=2))
node = {}
if NODE.exists():
    try: node = json.loads(NODE.read_text())
    except Exception: node = {}
if not node.get("id"):
    node["id"] = uuid.uuid4().hex[:8]; NODE.write_text(json.dumps(node, indent=2))
def _headers():
    h={}; 
    if cfg.get("token"): h["Authorization"] = f"Bearer {cfg['token']}"
    return h
def heartbeat():
    try:
        r = requests.get(f"{cfg['api_base']}/api/ping", headers=_headers(), timeout=8)
        return r.status_code, r.text[:200]
    except Exception as e:
        return 0, str(e)
def register_node():
    body={"id":node["id"],"name":node.get("name") or platform.node(),
          "room":os.getenv("ATOM_ROOM","team"),"platform":platform.platform(),
          "latlon": json.loads(os.getenv("ATOM_LATLON","[]") or "[]") if os.getenv("ATOM_LATLON") else None}
    try: requests.post(f"{cfg['api_base']}/api/agent/register", json=body, headers=_headers(), timeout=5)
    except Exception: pass
def heartbeat_node():
    body={"id":node["id"],"room":os.getenv("ATOM_ROOM","team"),"info":{"name": node.get("name") or platform.node()}}
    try: requests.post(f"{cfg['api_base']}/api/agent/heartbeat", json=body, headers=_headers(), timeout=5)
    except Exception: pass
def maybe_self_update():
    url = cfg.get("update_url")
    if not url: return
    try:
        r = requests.get(url, timeout=10)
        if r.status_code != 200: return
        new_src = r.text; me = pathlib.Path(__file__)
        cur_src = ""
        try: cur_src = me.read_text(encoding="utf-8", errors="ignore")
        except Exception: pass
        if new_src != cur_src:
            tmp = me.with_suffix(".py.new"); tmp.write_text(new_src, encoding="utf-8"); shutil.move(str(tmp), str(me))
            print("[atom-agent] self-updated from", url)
            os.execv(sys.executable, [sys.executable, str(me)])
    except Exception as e:
        print("[atom-agent] self-update failed:", e)
if __name__ == "__main__":
    print("[atom-agent] config:", cfg)
    register_node(); last_check = 0.0
    while True:
        code,msg = heartbeat(); heartbeat_node(); print(f"[atom-agent] ping -> {code} {msg}")
        now=time.time()
        if now - last_check > 86400: last_check = now; maybe_self_update()
        time.sleep(30)
