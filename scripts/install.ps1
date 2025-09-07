
Atom Node bootstrap (Windows)
$ErrorActionPreference = 'Stop'
$Root = Join-Path $env:ProgramData 'AtomNode'
$Py = Join-Path $Root 'venv\Scripts\python.exe'
$AgentDir = Join-Path $Root 'agent'
$AgentPy = Join-Path $AgentDir 'atom_agent.py'
$ApiBase = $env:ATOM_API_BASE; if (-not $ApiBase) { $ApiBase = 'http://144.202.23.216' }

New-Item -ItemType Directory -Force -Path $Root,$AgentDir | Out-Null

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
Write-Host 'Python 3.10+ required. Please install from https://www.python.org/downloads/ and re-run.' -ForegroundColor Yellow
exit 1
}

if (-not (Test-Path (Join-Path $Root 'venv'))) { python -m venv (Join-Path $Root 'venv') }
& $Py -m pip install --upgrade pip wheel > $null
& $Py -m pip install requests > $null

iwr -useb https://raw.githubusercontent.com/hophard/atom-node/main/agent/atom_agent.py -OutFile $AgentPy

@"
{
"api_base": "$ApiBase",
"token": ""
}
"@ | Set-Content (Join-Path $Root 'config.json') -Encoding UTF8

try {
$Action = New-ScheduledTaskAction -Execute $Py -Argument $AgentPy
$Trigger = New-ScheduledTaskTrigger -AtLogOn
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel LeastPrivilege
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries)
Register-ScheduledTask -TaskName "AtomNodeAgent" -InputObject $Task -Force | Out-Null
} catch {}

Start-Process -FilePath $Py -ArgumentList $AgentPy -WindowStyle Hidden
Write-Host "`n[OK] Atom Node installed. Config: $Root\config.json"
