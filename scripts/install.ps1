$ErrorActionPreference='Stop'
$root = Join-Path $env:USERPROFILE '.atomnode'
$venv = Join-Path $root 'venv'
$agentDir = Join-Path $root 'agent'
$agentPy = Join-Path $agentDir 'atom_agent.py'
$apiBase = if (![string]::IsNullOrWhiteSpace($env:ATOM_API_BASE)) { $env:ATOM_API_BASE } else { 'http://144.202.23.216' }

New-Item -ItemType Directory -Force -Path $agentDir | Out-Null
py -m venv "$venv" 2>$null; if (-not (Test-Path "$venv\Scripts\python.exe")) { python -m venv "$venv" }
& "$venv\Scripts\python.exe" -m pip install --upgrade pip wheel | Out-Null
& "$venv\Scripts\python.exe" -m pip install requests | Out-Null

Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/hophard/atom-node/main/agent/atom_agent.py" -OutFile "$agentPy"

try {
  $act = New-ScheduledTaskAction -Execute (Join-Path "$venv" 'Scripts\python.exe') -Argument "`"$($agentPy)`""
  $trg = New-ScheduledTaskTrigger -AtLogOn
  try { Unregister-ScheduledTask -TaskName 'AtomNodeAgent' -Confirm:$false -ErrorAction SilentlyContinue } catch {}
  Register-ScheduledTask -TaskName 'AtomNodeAgent' -Action $act -Trigger $trg -Description 'Atom Node agent' | Out-Null
  Write-Host "[OK] Task 'AtomNodeAgent' installed (runs at logon)"
} catch {
  try {
    $startup = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup'
    $ws = New-Object -ComObject WScript.Shell
    $lnk = $ws.CreateShortcut((Join-Path $startup 'AtomNodeAgent.lnk'))
    $lnk.TargetPath = (Join-Path "$venv" 'Scripts\python.exe')
    $lnk.Arguments  = "`"$($agentPy)`""
    $lnk.WorkingDirectory = $agentDir
    $lnk.Save()
    Write-Host "[OK] Startup shortcut created"
  } catch { Write-Warning "Auto-start not configured: $($_.Exception.Message)" }
}
