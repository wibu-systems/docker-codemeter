#!/usr/bin/env bash
# Cheap filter to only allow GET requests
set -euo pipefail

# Upstream Docker socket (exported by the entrypoint; falls back to default).
RAW_DOCKER_SOCKET="${RAW_DOCKER_SOCKET:-/var/run/docker.sock}"

# Read the request line (up to the first CR/LF).
IFS= read -r request_line || exit 0
# for easy HTTP-methode filtering
request_line="${request_line%$'\r'}"
method="${request_line%% *}"

if [ "${method}" != "GET" ]; then
    printf 'HTTP/1.1 403 Forbidden\r\n'
    printf 'Content-Type: text/plain\r\n'
    printf 'Content-Length: 32\r\n'
    printf 'Connection: close\r\n'
    printf '\r\n'
    printf 'Only GET requests are permitted.\n'
    exit 0
fi

# Re-emit the request line we consumed, then stream the rest of the request
# straight through to the Docker socket and relay the response back.
{
    printf '%s\r\n' "${request_line}"
    cat
} | socat - "UNIX-CONNECT:${RAW_DOCKER_SOCKET}"