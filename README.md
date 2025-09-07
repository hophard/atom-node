# Atom Node

Minimal local agent that pings your lobby and can be extended later.

> Model: <!--MODEL-VERSION-->unknown<!--/MODEL-VERSION-->

## Quick install (Windows)

`powershell
iwr -useb https://raw.githubusercontent.com/hophard/atom-node/main/scripts/install.ps1 | iex
Notes
Autostart via Scheduled Task AtomNodeAgent.

Config: %USERPROFILE%\.atomnode\config.json.

Agent source: agent/atom_agent.py (self-updates from this repo).
