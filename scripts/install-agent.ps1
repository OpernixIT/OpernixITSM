param(
  [Parameter(Mandatory=$true)][string]$PackageUrl,
  [Parameter(Mandatory=$true)][string]$ServerUrl,
  [Parameter(Mandatory=$true)][string]$AgentKey,
  [string]$InstallDir = "$env:ProgramFiles\NexusIT Agent"
)
$ErrorActionPreference = 'Stop'
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  throw 'Run PowerShell as Administrator.'
}
$work = Join-Path $env:TEMP ('nexusit-agent-' + [guid]::NewGuid())
New-Item -ItemType Directory -Force -Path $work | Out-Null
$zip = Join-Path $work 'agent.zip'
Invoke-WebRequest -Uri $PackageUrl -OutFile $zip -UseBasicParsing
Expand-Archive -Path $zip -DestinationPath $work -Force
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Copy-Item "$work\package\*" $InstallDir -Recurse -Force
$config = @{
  server_url = $ServerUrl.TrimEnd('/')
  agent_key = $AgentKey
  interval_seconds = 30
  timeout_seconds = 8
} | ConvertTo-Json
$config | Set-Content (Join-Path $InstallDir 'agent_config.json') -Encoding UTF8
$nssm = Join-Path $InstallDir 'nssm.exe'
$exe = Join-Path $InstallDir 'NexusITAgent.exe'
if (-not (Test-Path $nssm)) { throw 'nssm.exe is missing from the agent release.' }
if (-not (Test-Path $exe)) { throw 'NexusITAgent.exe is missing from the agent release.' }
& $nssm stop NexusITAgent | Out-Null
& $nssm remove NexusITAgent confirm | Out-Null
& $nssm install NexusITAgent $exe
& $nssm set NexusITAgent AppDirectory $InstallDir
& $nssm set NexusITAgent DisplayName 'NexusIT Agent'
& $nssm set NexusITAgent Start SERVICE_DELAYED_AUTO_START
& $nssm set NexusITAgent AppExit Default Restart
& $nssm set NexusITAgent AppRestartDelay 10000
& $nssm set NexusITAgent AppStdout (Join-Path $InstallDir 'agent-service.log')
& $nssm set NexusITAgent AppStderr (Join-Path $InstallDir 'agent-service-error.log')
& $nssm start NexusITAgent
Start-Sleep -Seconds 3
Get-Service NexusITAgent
Remove-Item $work -Recurse -Force
