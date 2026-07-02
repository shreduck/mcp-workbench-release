#!/bin/sh
set -eu
cd "$(dirname "$0")"

REQUIRED_JAVA_MAJOR=22

warn_java() {
	echo "MCP Workbench requires Java ${REQUIRED_JAVA_MAJOR} or newer." >&2
	if [ "${JAVA_VERSION:-}" ]; then
		echo "Detected Java version: ${JAVA_VERSION}." >&2
	else
		echo "Java was not found on PATH." >&2
	fi
	echo "Install Java ${REQUIRED_JAVA_MAJOR} or newer, or download the macOS with-JRE zip." >&2
}

if ! command -v java >/dev/null 2>&1; then
	warn_java
	exit 1
fi

JAVA_VERSION="$(java -version 2>&1 | awk -F '"' '/version/ { print $2; exit }')"
JAVA_MAJOR="$(printf '%s\n' "${JAVA_VERSION}" | awk -F '[.+-]' '{ if ($1 == "1") print $2; else print $1 }')"

case "${JAVA_MAJOR}" in
	''|*[!0-9]*)
		warn_java
		exit 1
		;;
esac

if [ "${JAVA_MAJOR}" -lt "${REQUIRED_JAVA_MAJOR}" ]; then
	warn_java
	exit 1
fi

exec java -jar mcp-workbench-launcher.jar "$@"
