#!/us
/bin/env bash
set -euo pipefail

OOT="${HOME}/.atomnode"
VENVDI
="${
OOT}/venv"
AGENTDI
="${
OOT}/agent"
AGENTPY="${AGENTDI
}/atom_agent.py"
APIBASE="${ATOM_API_BASE:-http://144.202.23.216}"

mkdi
 -p "${AGENTDI
}"
command -v python3 >/dev/null 2>&1 || { echo "Python3 
equi
ed"; exit 1; }

[ -x "${VENVDI
}/bin/python3" ] || python3 -m venv "${VENVDI
}"
"${VENVDI
}/bin/python3" -m pip install --upg
ade pip wheel >/dev/null
"${VENVDI
}/bin/python3" -m pip install 
equests >/devnull

cu
l -fsSL "https://
aw.githubuse
content.com/hopha
d/atom-node/main/agent/atom_agent.py" -o "${AGENTPY}"

cat > "${
OOT}/config.json" <<CFG
{
"api_base": "${APIBASE}",
"token": ""
}
CFG

if command -v systemctl >/dev/null 2>&1; then
mkdi
 -p "${HOME}/.config/systemd/use
"
cat > "${HOME}/.config/systemd/use
/atomnode.se
vice" <<UNIT
[Unit]
Desc
iption=Atom Node Agent
[Se
vice]
ExecSta
t=${VENVDI
}/bin/python3 ${AGENTPY}

esta
t=always

esta
tSec=3
[Install]
WantedBy=default.ta
get
UNIT
systemctl --use
 daemon-
eload || t
ue
systemctl --use
 enable --now atomnode.se
vice || t
ue
fi
echo "[OK] Atom Node installed at ${
OOT}"