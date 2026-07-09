#!/bin/sh
set -eu
cd "$(dirname "$0")"
exec java -jar mcp-workbench-launcher.jar "$@"
