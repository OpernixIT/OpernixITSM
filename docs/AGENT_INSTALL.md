# OpernixIT Agent installation

The public repository must not contain the agent Python source or the agent key. Publish the compiled agent ZIP as a **private GitHub Release asset** or on an authenticated download server.

## Expected release ZIP layout

```text
package/
  OpernixITAgent.exe
  nssm.exe
```

Do not place `agent_config.json` in the release. It is created during installation.

## Build the agent in the private source repository

On a controlled Windows build machine:

```cmd
cd agent
build_agent_exe.bat
```

Copy these files into `package/` and create a ZIP:

```text
agent/dist/OpernixITAgent.exe
agent/nssm.exe
```

Upload the resulting ZIP to a private release/download location.

## Install on one Windows computer

Open PowerShell as Administrator in this deployment repository:

```powershell
Set-ExecutionPolicy Bypass -Scope Process
.\scripts\install-agent.ps1 `
  -PackageUrl "https://YOUR-AUTHENTICATED-DOWNLOAD/OpernixITAgent-1.0.0.zip" `
  -ServerUrl "https://opernixit.company.example" `
  -AgentKey "THE_KEY_CREATED_IN_OPERNIXIT"
```

Check the service:

```powershell
Get-Service OpernixITAgent
Get-Content "C:\Program Files\OpernixIT Agent\agent-service-error.log" -Tail 100
```

## Domain deployment

For Active Directory environments, deploy the compiled ZIP or MSI through GPO/SCCM/Intune. Do not embed the shared secret in a public script. Store it in a protected GPO startup script, Intune secure variable, or issue a separate key for each device.

## Security

- Use HTTPS for `ServerUrl`.
- Rotate any agent key that has ever been committed or shared.
- Prefer per-device credentials instead of one universal key.
- Restrict `/api/agent/checkin` to trusted networks where possible.
