# MCP Workbench

MCP Workbench is a local server and desktop-friendly control panel for connecting Claude to your
work tools. It brings Azure DevOps, GitHub, backlog planning, Kanban boards, pull request review, and
agent kit files into one private workspace that runs on your machine or on your own server.

## What You Get

- A browser portal at `http://localhost:9999`
- Per-user sign-in and MCP access keys
- Azure DevOps and GitHub setup pages
- Local Backlog, Kanban, and PR Analysis workspaces
- Agent Kit files that can be edited, reverted, and downloaded
- Docker files for a server install
- A portable Windows launcher
- A portable macOS launcher

## Run With Docker

Download or clone this release repository, then start the server from the `docker` folder:

```bash
cd docker
docker compose up -d
```

Open:

```text
http://localhost:9999
```

The first sign-in uses:

```text
Username: admin
Password: changeit
```

Change the password from the Account page after signing in.

## Run The Published Image Directly

```bash
mkdir -p mcp-workbench-data
docker run --rm \
  -p 9999:9999 \
  -v "$PWD/mcp-workbench-data:/app/data" \
  ghcr.io/shreduck/mcp-workbench-release:latest
```

## Run On Windows

Download the Windows launcher zip from the latest GitHub release, extract it, and run:

```text
run-mcp-workbench.bat
```

The launcher starts MCP Workbench locally and keeps its data beside the launcher folder.

You can also download the server jar from the latest GitHub release and double-click it on Windows
if Java is installed and associated with `.jar` files.

## Run On macOS

Download the macOS launcher zip from the latest GitHub release and extract it. If the archive
contains `MCP Workbench.app`, run that app. The Java-only launcher folder can be started with:

```text
run-mcp-workbench.command
```

The launcher stores its default data under `~/Library/Application Support/MCP Workbench`. If you
enable start at login, it creates a current-user LaunchAgent under `~/Library/LaunchAgents`.

## Connect Claude

1. Open the portal.
2. Go to Account.
3. Generate an MCP key.
4. Open Help.
5. Copy the generated Claude configuration for your client.

The MCP endpoint is:

```text
http://localhost:9999/mcp
```

Use the key shown by the portal when connecting Claude.

## Data And Secrets

MCP Workbench stores its local data under the configured app data folder. When using Docker, mount
`/app/data` to keep your database, settings, keys, and history across restarts.

Tokens and credentials are encrypted before they are stored. Keep your data folder private and back
it up if you rely on the workspace history.

## Downloads

Each release includes:

- the server jar
- SHA-256 checksums
- Docker files
- the Windows launcher zip
- the macOS launcher zip
- this README
- the license
