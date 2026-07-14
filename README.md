<p align="center">
  <h1 align="center">OpernixIT</h1>
  <p align="center">
    Self-hosted IT Service Management, Asset Management and Endpoint Operations Platform
  </p>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Docker-Supported-2496ED?logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/SQLite-%2307405e.svg?logo=sqlite&logoColor=white" alt="SQLite">
  <img src="https://custom-icon-badges.demolab.com/badge/Windows-0078D6?logo=windows11&logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black" alt="Linux">
  <img src="https://img.shields.io/badge/Languages-English%20%7C%20Türkçe-7C3AED" alt="Languages">
  <img src="https://img.shields.io/badge/Deployment-Private%20Container-111827" alt="Private Container">
</p>

> [!IMPORTANT]
> This repository contains deployment files only. The OpernixIT application source code is not included. Application images are distributed through a private container registry.

## Overview

OpernixIT is a self-hosted IT management platform designed for internal IT teams. It combines helpdesk operations, access requests, asset tracking, endpoint monitoring and operational reporting in a single interface.

Core capabilities include:

- Ticket and helpdesk management
- E-mail-to-ticket through `helpdesk@your-domain.com`
- Access request workflows
- Asset, assignment and warranty management
- Windows endpoint agent monitoring
- Software license tracking
- Problem and change management
- Inventory counts and QR workflows
- Release and update management
- Audit logs and operational reports
- English and Turkish interface

## Interface

### Executive Dashboard

<p align="center">
  <img src="docs/img/dashboard.png" alt="OpernixIT Executive Dashboard" width="100%">
</p>

### Ticket and Operations View

<p align="center">
  <img src="docs/img/dashboard2.png" alt="OpernixIT Ticket and Operations View" width="100%">
</p>

## Deployment Architecture

```text
Users
  │
  ▼
OpernixIT Web Application
  │
  ├── PostgreSQL Database
  ├── Persistent Upload Storage
  ├── Runtime Configuration
  └── Windows Endpoint Agents
```

The application runs from a private Docker image. PostgreSQL data, uploaded files and runtime settings are stored in persistent Docker volumes.

## Requirements

- Linux server
- Docker Engine 24 or newer
- Docker Compose v2
- Access to the private OpernixIT container registry
- Minimum 2 CPU cores
- Minimum 4 GB RAM
- Minimum 20 GB free disk space

## Quick Installation

### 1. Clone the deployment repository

```bash
git clone https://github.com/shotlasts/OpernixITSM.git
cd opernixit-deploy
```

### 2. Create the environment file

```bash
cp .env.example .env
```

Edit `.env`:

```env
OPERNIXIT_IMAGE=ghcr.io/shotlasts/opernixit
OPERNIXIT_VERSION=1.0.0

POSTGRES_DB=opernixit
POSTGRES_USER=opernixit
POSTGRES_PASSWORD=CHANGE_THIS_PASSWORD

APP_PORT=5000
TZ=Europe/Istanbul
```

Use a long and unique PostgreSQL password.

### 3. Sign in to the private registry

Create a GitHub token with permission to read packages, then run:

```bash
echo "$GHCR_TOKEN" | docker login ghcr.io -u YOUR-USERNAME --password-stdin
```

### 4. Start OpernixIT

```bash
docker compose -f docker-compose.private.yml up -d
```

Check the containers:

```bash
docker compose -f docker-compose.private.yml ps
```

### 5. Open the setup wizard

```text
http://SERVER-IP:5000/setup
```

During the first setup you can configure:

- Company name
- System name
- Default language
- PostgreSQL connection
- Super administrator account
- Support e-mail address
- Basic application settings

## Updating OpernixIT

Set the new version in `.env`:

```env
OPERNIXIT_VERSION=1.0.1
```

Pull and apply the update:

```bash
docker compose -f docker-compose.private.yml pull
docker compose -f docker-compose.private.yml up -d
```

Persistent database and uploaded files are preserved during updates.

> [!WARNING]
> Do not use `docker compose down -v`. The `-v` option removes persistent volumes and can delete the database.

## Useful Commands

View running services:

```bash
docker compose -f docker-compose.private.yml ps
```

View application logs:

```bash
docker compose -f docker-compose.private.yml logs -f app
```

View PostgreSQL logs:

```bash
docker compose -f docker-compose.private.yml logs -f db
```

Restart the application:

```bash
docker compose -f docker-compose.private.yml restart app
```

Stop OpernixIT without deleting data:

```bash
docker compose -f docker-compose.private.yml down
```

Start OpernixIT again:

```bash
docker compose -f docker-compose.private.yml up -d
```

## Windows Agent Installation

The Windows agent collects endpoint inventory and health information and sends it to the OpernixIT server.

Run PowerShell as Administrator:

```powershell
Set-ExecutionPolicy Bypass -Scope Process
```

Install the agent:

```powershell
.\scripts\install-agent.ps1 `
  -PackageUrl "https://downloads.example.com/OpernixITAgent-1.0.0.zip" `
  -ServerUrl "https://opernixit.example.com" `
  -AgentKey "YOUR-AGENT-KEY"
```

The installer:

- Installs the agent under `C:\Program Files\OpernixIT Agent`
- Creates the `OpernixITAgent` Windows service
- Enables delayed automatic startup
- Restarts the service automatically after failures
- Creates the agent configuration file
- Writes service logs locally

Check the service:

```powershell
Get-Service OpernixITAgent
```

Restart the service:

```powershell
Restart-Service OpernixITAgent
```

Read the error log:

```powershell
Get-Content "C:\Program Files\OpernixIT Agent\agent-service-error.log" -Tail 100
```

## Domain Deployment

For Active Directory environments, the agent can be distributed with a Computer Startup PowerShell script through Group Policy.

Recommended approach:

1. Store the agent package on a protected internal file share.
2. Keep the installation script in a read-only deployment folder.
3. Deploy the script through `Computer Configuration → Windows Settings → Scripts → Startup`.
4. Use HTTPS for communication with the OpernixIT server.
5. Rotate agent keys periodically.
6. Do not publish agent keys in GitHub repositories.

## Security Notes

- Keep the application source repository private.
- Keep the Docker container image private.
- Never commit `.env` files.
- Never commit agent keys or private signing keys.
- Use HTTPS in production.
- Restrict PostgreSQL access to the Docker network.
- Use read-only registry tokens for customer deployments.
- Back up PostgreSQL volumes regularly.
- Apply signed OpernixIT update packages only.

## Repository Structure

```text
opernixit-deploy/
├── README.md
├── .env.example
├── docker-compose.private.yml
├── docs/
│   └── img/
│       ├── dashboard.png
│       └── dashboard2.png
└── scripts/
    ├── install-agent.ps1
    └── update-opernixit.sh
```

## Backup

Create a PostgreSQL backup:

```bash
docker compose -f docker-compose.private.yml exec -T db \
  pg_dump -U opernixit opernixit > opernixit-backup.sql
```

Restore a backup:

```bash
cat opernixit-backup.sql | docker compose -f docker-compose.private.yml exec -T db \
  psql -U opernixit -d opernixit
```

Store backups outside the application server whenever possible.

## Support

For technical support and deployment assistance:

```text
helpdesk@your-domain.com
```

## License

OpernixIT is proprietary software. Deployment files in this repository do not grant access to the application source code, container image or commercial license.

Unauthorized copying, redistribution, reverse engineering or resale is prohibited.

---

<p align="center">
  Built for modern IT operations.
</p>
