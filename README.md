# NexusIT Deployment Repository

This repository intentionally contains **no NexusIT application source code**. It deploys a private, prebuilt Docker image and PostgreSQL.

## Repository model

- `nexusit-source` — **private repository**: application source, Dockerfile, Nuitka and agent builds.
- `nexusit-deploy` — this repository: may be public; contains only Compose and installation documentation.

Making the source repository public makes the Python/HTML/CSS/JavaScript source visible. GitHub cannot hide files in a public repository.

## Docker installation

```bash
git clone https://github.com/YOUR_ORG/nexusit-deploy.git
cd nexusit-deploy
cp .env.example .env
nano .env
```

Authenticate to the private container registry:

```bash
echo "$GHCR_TOKEN" | docker login ghcr.io -u YOUR_GITHUB_USER --password-stdin
```

Start:

```bash
./scripts/start.sh
```

Open:

```text
http://SERVER_IP:5000/setup
```

Use these database values in the setup wizard:

```text
Host: db
Port: 5432
Database: nexusit
User: nexusit
Password: the POSTGRES_PASSWORD value in .env
```

## Updating

Change `NEXUSIT_VERSION` in `.env`, then run:

```bash
./scripts/update.sh
```

Do not run `docker compose down -v`; `-v` deletes database volumes.

## Agent

See `docs/AGENT_INSTALL.md`.
