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
- Windows launcher zips with and without a bundled Java runtime
- macOS launcher zips with and without a bundled Java runtime

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

The default HTTP/WS endpoint favors easy local development. Before exposing Workbench to an
untrusted or corporate network, use the home-screen hardening checklist to enable HTTPS/WSS,
configure a trusted certificate or reverse proxy, restrict network access, and replace the bootstrap
password.

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

For the easiest install, download `mcp-workbench-windows-with-jre-<version>.zip` from the latest
GitHub release, extract it, and run:

```text
MCP Workbench.exe
```

This zip includes the Java runtime needed by MCP Workbench.

From this public release repository, you can also install or update the newest public Windows
with-JRE zip without GitHub CLI:

```bat
scripts\install-windows-release.cmd
```

By default, it installs to `%USERPROFILE%\Apps\MCP Workbench` and preserves local `data\` and
`mcp-workbench-launcher.properties` files.

If you already have Java 22 or newer installed, you can instead download
`mcp-workbench-windows-launcher-<version>.zip`, extract it, and run:

```text
run-mcp-workbench.bat
```

The Java-only launcher warns before startup when Java is missing or older than Java 22.

You can also download the server jar from the latest GitHub release and double-click it on Windows
if Java is installed and associated with `.jar` files.

## Run On macOS

For the easiest install, download `mcp-workbench-mac-with-jre-<version>.zip` from the latest GitHub
release, extract it, and run:

```text
MCP Workbench.app
```

This zip includes the Java runtime needed by MCP Workbench.

If you already have Java 22 or newer installed, you can instead download
`mcp-workbench-mac-launcher-<version>.zip`, extract it, and run:

```text
run-mcp-workbench.command
```

The Java-only launcher warns before startup when Java is missing or older than Java 22.

The launcher stores its default data under `~/Library/Application Support/MCP Workbench`. If you
enable start at login, it creates a current-user LaunchAgent under `~/Library/LaunchAgents`.

## Connect An Agent

1. Open the portal.
2. Go to Account.
3. Create an MCP key.
4. Open Connect.
5. Copy the generated configuration for your client.

The MCP endpoint is:

```text
http://localhost:9999/mcp
```

Prefer the key as a Bearer token:

```text
Authorization: Bearer <your MCP key>
```

Use this URL fallback only for clients or bridges that cannot send headers:

```text
http://localhost:9999/mcp?mcp_key=<your MCP key>
```

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
- the Windows launcher zip for installed Java 22+
- the Windows with-JRE zip
- the macOS launcher zip for installed Java 22+
- the macOS with-JRE zip
- this README
- the license

Large runtime and desktop launcher binaries are published as GitHub Release assets rather than
stored in this Git repository. This keeps ordinary clones small and avoids Git hosting object-size
limits.
