# MCP Workbench

MCP Workbench is a local-first control center for AI-assisted engineering. It gives Codex, Claude
Code, GitHub Copilot, Grok, and other MCP clients one governed endpoint for planning, code
intelligence, browser automation, repository workflows, and auditable agent reasoning.

![MCP Workbench home dashboard](docs/images/readme/home-dashboard.png)

The portal uses an embedded H2 database by default and can use PostgreSQL for shared/server
deployments. External systems are contacted only through the integrations you configure, and every
MCP key can be limited to the tools its agent actually needs.

## Why use it?

- **One governed toolset.** Give each agent one scoped MCP key for the workflows it needs.
- **Approval-first changes.** Review proposed repository and work-item changes before they reach a
  remote system.
- **Release-aware repository research.** Find pull requests between tags or commits and retrieve Git
  history with the pull requests associated to each commit.
- **Local, inspectable work.** Boards, analyses, traces, policies, credentials, and audit records stay
  in the configured application data directory.
- **Isolated execution.** Browser tools use fresh profiles, while Fetch Proxy keeps large or delegated
  results temporary and bounded.

## How it fits together

```mermaid
flowchart LR
    AI["Codex / Claude Code / Copilot / Grok"] -->|"Streamable HTTP + scoped MCP key"| MCP["MCP Workbench"]
    MCP --> UI["Local web portal"]
    MCP --> DB[("H2 or PostgreSQL data")]
    MCP --> REMOTE["Azure DevOps / GitHub"]
    MCP --> BROWSER["Isolated browser"]
    MCP --> FETCH["Fetch Proxy"]
    MCP --> HELPER["Optional proxy/helper"]
    HELPER --> LOCAL_BROWSER["Isolated browser near the user"]
```

Browser tools use the same operations in both supported execution paths:

```text
AI → MCP Workbench → Browser
AI → MCP Workbench → proxy/helper → Browser
```

The second path is useful when Workbench runs on another machine. The helper initiates an
authenticated connection to Workbench and executes the browser tools near the user without exposing
the user's normal browser profile.

## MCP tool groups

| Tools | How they work and what they are useful for |
| --- | --- |
| **Azure DevOps and GitHub** | Inspect repositories, branches, pull requests, comments, diffs, files, work items, and issues. `getAzurePullRequestSearchSupport` and `getGitHubPullRequestSearchSupport` describe provider filters; `searchAzurePullRequests` and `searchGitHubPullRequests` can bound a release by tags or commits, while `getAzureGitHistory` and `getGitHubGitHistory` return commits with associated pull requests. These tools are suited to release notes, change audits, and repository research. |
| **Kanban** | Create and search persistent boards and cards, move work, add comments and links, and return portal links so an agent can hand a task back to a person. |
| **PR Analysis** | Build local Azure DevOps or GitHub review records, organize findings and discussion, and publish only selected comments after review. |
| **Backlog** | Record conversations and prepare versioned Azure DevOps or GitHub work-item, issue, test-plan, and pull-request proposals. Remote pushes remain explicit, scoped actions. |
| **Agent Kits and Spec Docs** | Store reusable agent instructions and project documentation with folders, history, search, stable slugs, and portal links. |
| **Think Trace** | Record typed reasoning nodes, edges, evidence, comments, and reports so an agent run can be searched, reviewed, and compared later. |
| **Code Scanner** | Index local, Azure DevOps, or GitHub code; search symbols and files; follow calls and references; find entry points, service APIs, configuration, Data I/O, Maven structure, quality findings, and CVEs. |
| **Browser Automation** | Start isolated direct or helper-backed browsers, navigate, inspect semantic snapshots, interact with elements, annotate pages, read console output, and capture screenshots. |
| **Fetch Proxy** | Fetch policy-approved web content or delegate an allowed MCP tool, then poll, search, and read temporary results in bounded parts. |
| **Tool catalogue** | `getMcpApiDocs` returns the currently exposed MCP tool descriptions and schemas for discovery without relying on a stale hard-coded list. |

## Product tour

### Plan work and review changes

Kanban tools keep planning work persistent and return direct links agents can hand back to a user.

![Kanban board populated with a release plan](docs/images/readme/kanban-board.png)

PR Analysis tools turn Azure DevOps or GitHub reviews into structured local findings with a
controlled path for publishing selected comments.

![Pull request analysis with synthetic findings](docs/images/readme/pr-analysis.png)

The release-aware repository tools first describe their supported filters, then search pull requests
or walk commit history within an optional tag or commit range. Repository Query presents those MCP
workflows for people, including commit-to-PR associations, linked Azure work item IDs, page grouping, pagination, and export.

![Repository Query release-range search](docs/images/readme/repository-query.png)

### Repeat browser and JVM measurements

[Test Suite](docs/test-suite.md) groups reusable measurement profiles and saved runs in folders
such as `App/sortB`. An agent can start `App#sortB`, interact through existing browser tools,
then stop by run ID. Browser and JVM evidence share an explorable timeline, with repeated-run
overlays and saved environment metadata. Stop leaves the application and browser open.

![Test Suite combined browser and JVM timeline](docs/images/test-suite/runs-1920.png)

### Make agent reasoning inspectable

Think Trace tools record a run as typed nodes and edges instead of hiding it in a chat transcript.
Reports, comments, evidence, decisions, and changes remain inspectable together.

![Think Trace overview with graph and details](docs/images/readme/think-trace.png)

The expanded graph makes the full execution path easier to present or audit.

![Expanded Think Trace graph](docs/images/readme/think-trace-expanded.png)

### Explore a codebase without pasting it into chat

Code Scanner tools index local folders or authenticated Azure DevOps and GitHub branches, then add
deterministic Java symbol, configuration, entry-point, reference, Data I/O, Maven dependency, and CVE
analysis.

![Code Scanner analysis overview](docs/images/readme/code-scanner.png)

Hierarchy search turns a focused symbol into a navigable reference graph. The screenshot shows
names and relationships only—not source bodies.

![Code Scanner hierarchy search graph](docs/images/readme/code-scanner-hierarchy.png)

Entry-point browsing brings HTTP endpoints, MCP tools, listeners, and service APIs into one filterable
view.

![Code Scanner entry-point browser](docs/images/readme/code-scanner-entrypoints.png)

### Connect agents and controlled execution

The Connect page provides client-specific setup and a searchable inventory of the MCP tools enabled
for the current key.

![Connect an agent tutorial](docs/images/readme/connect-an-agent.png)

Browser tools discover installed Chromium, Chrome, Brave, and Firefox executables and use reusable
hardened configurations for direct or helper-backed sessions.

![Browser Automation configuration](docs/images/readme/browser-automation.png)

Fetch Proxy tools apply global and per-key policy to outbound HTTP fetches and delegated tool results.

![Fetch Proxy policy and limits](docs/images/readme/fetch-proxy.png)

The portal supplies human views for these tool groups plus credentials, per-key permissions, browser
and Fetch Proxy policy, persistence, connectivity, and audit logs. It is an operator interface; agent
automation uses the scoped MCP tools described above.

## Install

### Recommended: desktop bundle

Download the latest bundle from
[MCP Workbench Releases](https://github.com/shreduck/mcp-workbench-release/releases/latest).
Release assets include SHA-256 checksum files.

#### Windows

1. Download `mcp-workbench-windows-with-jre-<version>.zip`.
2. Extract it to a writable folder.
3. Run `MCP Workbench.exe`.
4. Confirm the data directory and port. The defaults are `data\` beside the executable and `9999`.
5. Select **Open Browser** when the server is ready.

The launcher can start Workbench when you sign in and otherwise stays available from the system
tray. If Java 22 or newer is already on `PATH`, the smaller
`mcp-workbench-windows-launcher-<version>.zip` can be used instead; start it with
`run-mcp-workbench.bat`.

#### macOS

1. Download `mcp-workbench-mac-with-jre-<version>.zip`.
2. Extract it and move `MCP Workbench.app` where you want to keep it.
3. Open the app and confirm the data directory and port. The defaults are
   `~/Library/Application Support/MCP Workbench/data` and `9999`.
4. Select **Open Browser** when the server is ready.

The launcher can create a current-user login item and can remain available in the menu bar. If Java
22 or newer is already on `PATH`, use `mcp-workbench-mac-launcher-<version>.zip` and start
`run-mcp-workbench.command`.

MCP Workbench is currently distributed outside the Mac App Store. If macOS blocks the first launch:

1. Try to open `MCP Workbench.app` once, then dismiss the warning.
2. Open **Apple menu → System Settings → Privacy & Security**.
3. Authenticate and confirm **Open**.

Only override Gatekeeper after verifying that the archive and checksum came from the release
repository. Apple documents this flow in
[Open a Mac app from an unknown developer](https://support.apple.com/en-euro/guide/mac-help/mh40617/mac).

### Docker

The published image is `ghcr.io/shreduck/mcp-workbench`. Persist `/app/data`; the container runs as
UID/GID `1000`.

```bash
mkdir -p mcp-data
sudo chown 1000:1000 mcp-data
docker run --rm \
  -p 9999:9999 \
  -v "$PWD/mcp-data:/app/data" \
  ghcr.io/shreduck/mcp-workbench:latest
```

To build and run the checked-in Compose configuration:

```bash
cd docker
cp .env.example .env
docker compose up -d --build
```

### Executable jar or source

The release repository also provides `mcp-workbench-<version>.jar`, which requires Java 22 or newer:

```bash
APP_DATA_DIR="$PWD/mcp-data" java -jar mcp-workbench-<version>.jar
```

To build the current source:

```bash
mvn package
java -jar mcp-application/target/mcp-server.jar
```

For a development run:

```bash
mvn -pl :mcp-application -am spring-boot:run
```

Open `http://localhost:9999`. The initial local administrator is `admin` with password `changeit`;
change it immediately before exposing the service beyond a trusted development machine.

## Connect an AI client

1. Sign in to the portal and open **MCP APIs**.
2. Create a key with a descriptive label such as `codex-local`.
3. Limit the key to the apps that client should use and copy the secret when it is shown.
4. Open **Connect** and select the client tab for the exact configuration format.
5. Verify the connection with a read-only request, for example: “List the available MCP Workbench
   tools and do not change anything.”

The MCP endpoint is:

```text
http://localhost:9999/mcp
```

Use `Authorization: Bearer <key>` when the client supports custom headers. A URL-key fallback is
available for clients that cannot send headers, but headers avoid placing secrets in URLs, history,
or access logs.

## Security model

MCP Workbench is designed for trusted local or team-controlled deployment, with explicit controls at
each boundary:

- passwords and integration tokens are encrypted at rest using the configured application key;
- MCP keys are stored as hashes, shown once, independently scoped, auditable, and revocable;
- state-changing backlog and review workflows are approval-first; an MCP key's broad **Immediate remote
  writes** permission authorizes proposal pushes plus unscoped pull-request writes (comments and creation/update);
- Azure project configurations can separately grant assigned MCP keys work-item force pushes within selected
  ancestor subtrees, or Azure pull-request writes for exact target branches (or every branch in that project);
  GitHub pull-request writes always require the broad **Immediate remote writes** permission;
- Azure project configurations can publish enabled custom-field expectations to agents, normalized with a list of affected
  work-item types; field discovery runs only when requested in the portal, refreshes locked Azure metadata, and discovered
  fields can be disabled or deleted;
- audit entries record portal, MCP, macOS launcher, and Windows launcher identities;
- the home-page hardening card summarizes warnings and expands to the remediation details;
- application data can be reset by persistence unit or all at once by an administrator;
- external integrations are disabled until configured.

Do not expose port `9999` directly to an untrusted network. Put remote deployments behind TLS,
network access control, and an authenticating reverse proxy.

### Browser isolation

Browser Automation starts a fresh temporary profile for every session. It does not attach to the
user's everyday profile and therefore does not inherit saved passwords, history, cookies, extensions,
or active logins. A direct session is local to Workbench; a proxied session uses the same commands
through an authenticated helper near the browser.

The proxy connection is outbound, authenticated WSS. Workbench sends sanitized browser
configuration metadata and never needs to disclose local executable paths, environment overrides,
profile paths, or helper session identifiers. See the complete
[browser execution protocol](mcp-browser/docs/browser-execution-protocol.md).

### Fetch Proxy policy

Fetch Proxy is useful for both small sandbox-constrained fetches and results too large for one MCP
response. Its controls include:

- host and delegated-tool allow/deny rules, with deny taking precedence;
- per-key policy that can narrow but never widen the global policy;
- the ordinary MCP app entitlement check before a fetch starts;
- DNS and resolved-address protections for private or otherwise forbidden targets;
- safe request headers and HTTP `GET`/`HEAD` only;
- concurrency, byte, part-size, timeout, retention, and TTL limits.

Its clean 2.0.1 MCP surface is:

```text
startWebFetch
startToolFetch
getFetchResultStatus
listFetchResults
getFetchResultPart
searchFetchTextResult
deleteFetchResult
```

Earlier pre-release tool names are intentionally not retained as compatibility aliases.

## Configuration

Common environment variables:

| Variable | Purpose |
| --- | --- |
| `SERVER_PORT` | HTTP and MCP port; default `9999`. |
| `APP_DATA_DIR` | Persistent database, runtime, and application data root. |
| `APP_DATABASE_URL` | Primary JDBC URL. Defaults to the H2 file under `APP_DATA_DIR`; PostgreSQL URLs use `jdbc:postgresql://…`. |
| `APP_DATABASE_USERNAME` | Primary database username; default `sa` for H2. |
| `APP_DATABASE_PASSWORD` | Primary database password. |
| `APP_DATABASE_IMPORT_MAX_FILE_SIZE` | Maximum H2 `.mv.db` upload accepted by database migration; default `2GB`. |
| `APP_ENCRYPTION_KEY` | Stable secret used to protect stored credentials. Set this explicitly for persistent deployments. |
| `APP_TRUST_PROXY` | Trust forwarded headers only when Workbench is behind a correctly configured trusted proxy. |
| `APP_BROWSER_PROXY_ENABLED` | Permit configured cooperative browser helpers. |
| `APP_FETCH_PROXY_*` | Fetch Proxy limits and policy defaults; the portal exposes the supported settings. |

Spring Boot configuration can also be supplied through environment variables, JVM properties, or an
external configuration file. Keep the same `APP_ENCRYPTION_KEY` when moving an existing data
directory or its encrypted credentials will no longer be readable.

The Windows and macOS launchers expose these database values under the collapsible
**Advanced database options** section of the startup dialog. They persist `databaseUrl`,
`databaseUsername`, `databasePassword`, and `databaseImportMaxFileSize` in
`mcp-workbench-launcher.properties` and forward configured values to the server. Leave the JDBC URL
blank to keep using embedded H2. The launcher properties file stores the database password as plain
text, so protect it with normal user-only filesystem permissions.

For PostgreSQL, create an empty database and start Workbench with:

```bash
APP_DATABASE_URL="jdbc:postgresql://postgres.example:5432/mcp_workbench" \
APP_DATABASE_USERNAME="mcp_workbench" \
APP_DATABASE_PASSWORD="replace-me" \
java -jar mcp-server.jar
```

Liquibase creates or upgrades the schema at startup. To copy application data from another
Workbench database, open **Configuration → Database**, select an H2 `.mv.db` file or enter a
PostgreSQL JDBC URL, and scan it. Workbench compares Liquibase history, displays row counts by
application, Users, and System persistence group, exposes the exact source-only and
destination-only changesets, and asks which groups to replace. Matching schemas import directly;
older schemas require explicit acknowledgement, newer schemas show a non-blocking upgrade
suggestion and copy fields supported by the current version, while divergent or unrecognized
schemas are blocked. Sensitive Users and System cards require explicit selection. See
[database deployment and migration](docs/database.md) for the full behavior.

## Development

Prerequisites are JDK 22+ and Maven 3.8+.

```bash
mvn test
```

The reactor is split by capability:

```text
mcp-common              shared security, audit, and infrastructure
mcp-azure-devops        Azure DevOps read APIs
mcp-github              GitHub read and issue APIs
mcp-azure-tools         Azure DevOps project/tool support
mcp-kanban              local boards
mcp-pr-analysis         pull-request analysis
mcp-backlog             approval-first change proposals
mcp-think-trace         execution graphs
mcp-code-scanner        language and Maven analysis modules
mcp-fetch-proxy         bounded HTTP and delegated-tool results
mcp-browser             direct and proxied browser automation
mcp-management          portal, users, configuration, and audit UI
mcp-application         Spring Boot assembly
mcp-windows / mcp-mac   desktop launchers
```

Operational and publishing details live under [`docs/`](docs/). Humans can use **Repository Query**
in the portal; release automation clients should connect to `/mcp` and follow the
[release-aware pull request and Git history tool guide](docs/git-release-query-api.md). Browser
implementers should start with the protocol document linked above.

## License

MCP Workbench is source-available under the
[Research & Learning Commons License](LICENSE). Non-commercial personal, educational, and research
use is permitted by the license. Commercial or enterprise use requires written permission after the
single shared 30-day non-production evaluation. Contact `duck_code_contact@proton.me` for commercial
licensing.
