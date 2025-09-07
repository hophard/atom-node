#!/usr/bin/env bash
set -euo pipefail
ROOT="${HOME}/.atomnode"; VENVDIR="${ROOT}/venv"; AGENTDIR="${ROOT}/agent"; AGENTPY="${AGENTDIR}/atom_agent.py"
APIBASE="${ATOM_API_BASE:-http://144.202.23.216}"
mkdir -p "${AGENTDIR}"
command -v python3 >/dev/null 2>&1 || { echo "Python3 required"; exit 1; }
[ -x "${VENVDIR}/bin/python3" ] || python3 -m venv "${VENVDIR}"
"${VENVDIR}/bin/python3" -m pip install --upgrade pip wheel >/dev/null
"${VENVDIR}/bin/python3" -m pip install requests >/dev/null
curl -fsSL "https://raw.githubusercontent.com/hophard/atom-node/main/agent/atom_agent.py" -o "${AGENTPY}"
cat > "${ROOT}/config.json" <<CFG
{
  "api_base": "${APIBASE}",
  "token": ""
}
CFG
if command -v systemctl >/dev/null 2>&1; then
  mkdir -p "${HOME}/.config/systemd/user"
  cat > "${HOME}/.config/systemd/user/atomnode.service" <<'UNIT'
[Unit]
Description=Atom Node Agent
[Service]
ExecStart=%h/.atomnode/venv/bin/python %h/.atomnode/agent/atom_agent.py
Restart=always
RestartSec=3
[Install]
WantedBy=default.target
UNIT
  systemctl --user daemon-reload || true
  systemctl --user enable --now atomnode || true
fi
echo "[OK] Atom Node installed at ${ROOT}"