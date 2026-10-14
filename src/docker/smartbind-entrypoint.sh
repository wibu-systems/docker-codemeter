#!/usr/bin/env bash

# Entrypoint Wrapper script for CmActLicense with binding scheme SmartBind
#
# Environment variable RAW_DOCKER_SOCKET must point to the Docker socket mounted from the host

#! Security note:
#   Access to a Docker socket can provide root-equivalent access to the host.
#   This entrypoint reduces the exposed API to GET requests for CodeMeter,
#   but it is a defense-in-depth measure, not a complete security boundary.
#   Docker API responses may still contain sensitive container or host metadata.
#   A read-only (:ro) socket mount alone does not prevent API requests.

set -euo pipefail

log(){
  local msg="[SmartBind Wrapper] $1"
  echo "${msg}"
}

# Hard-coded because CodeMeter runs with this fixed service user
# This value is intentionally not configurable
CM_SERVICE_USER="codemeter-backend-classic"

# This value is intentionally not configurable
CMACT_DIRECTORY="/var/lib/CodeMeter/CmAct"

# Upstream Docker socket mounted from the host
#   The path can be overridden through the RAW_DOCKER_SOCKET environment variable
RAW_DOCKER_SOCKET="${RAW_DOCKER_SOCKET:-/mnt/docker-raw.sock}"

# CodeMeter expects the proxy socket at this fixed path
# The socket is created for CM_SERVICE_USER with permission mode 0600
PROXY_SOCK="/var/run/docker.sock"

# The default entrypoint, executed after the socket proxy is ready
DEFAULT_ENTRYPOINT="/entrypoint.sh"

if [ ! -S "${RAW_DOCKER_SOCKET}" ]; then
    log "Docker socket '${RAW_DOCKER_SOCKET}' not found or not a socket."
    exit 1
fi

if ! id "${CM_SERVICE_USER}" >/dev/null 2>&1; then
    log "User '${CM_SERVICE_USER}' does not exist."
    exit 1
fi

if [ -e "${PROXY_SOCK}" ]; then
  log "Proxy socket at '${PROXY_SOCK}' already exists."
  # Socket may exist if the container has been restarted, so check if the socket is pointing to the raw sock
  # if it does, its safe to remove the proxy & re-create it.
  if [ -S "${PROXY_SOCK}" ] && [ "${PROXY_SOCK}" -ef "${RAW_DOCKER_SOCKET}" ]; then
    log "Make sure RAW_DOCKER_SOCKET does NOT point to the same location as the PROXY_SOCK"
    log "RAW_DOCKER_SOCKET: '${RAW_DOCKER_SOCKET}' -> '${PROXY_SOCK}'"
    exit 1
  else
    # check if the proxy socket is a mount / volume from host
    if findmnt --mountpoint "${PROXY_SOCK}" >/dev/null 2>&1; then
      log "Proxy socket at '${PROXY_SOCK}' seems to be a mount."
      log "Please check your configuration"
      exit 1
    fi

    # Socket owner must be CM_SERVICE_USER
    socket_owner=$(stat -c '%U' /var/run/docker.sock)
    if [ "${socket_owner}" != "${CM_SERVICE_USER}" ]; then
      log "Proxy socket is not owned by the expected user "${CM_SERVICE_USER}""
      log "Please check your configuration"
      exit 1
    fi

    log "Assuming container has been restarted"
    log " -> Removing stale proxy socket '${PROXY_SOCK}'"
    rm ${PROXY_SOCK}
  fi
fi

if [ ! -d "${CMACT_DIRECTORY}" ]; then
  log "Missing CmAct directory for CmActLicense with SmartBind-Schema."
  exit 1
fi

# Change permissions for CmAct Mountpoint, if required.
#  Usually needed when updating from an older CodeMeter Version
# shellcheck disable=SC2016
log "Changing owner for '${CMACT_DIRECTORY}' to '${CM_SERVICE_USER}'"
chown -R ${CM_SERVICE_USER}:${CM_SERVICE_USER} "${CMACT_DIRECTORY}"

# Start the GET-only Docker-Socket proxy
# Access to the proxy socket is restricted to CM_SERVICE_USER
log "starting Docker GET-only proxy on ${PROXY_SOCK} for user '${CM_SERVICE_USER}'"

# UNIX-LISTEN options:
#   fork            -> handle multiple/parallel connections
#   reuseaddr       -> allow quick restarts
#   user/group/mode -> set socket ownership and restrict access to CM_SERVICE_USER

RAW_DOCKER_SOCKET="${RAW_DOCKER_SOCKET}" \
socat \
    "UNIX-LISTEN:${PROXY_SOCK},fork,reuseaddr,user=${CM_SERVICE_USER},group=${CM_SERVICE_USER},mode=0600" \
    "EXEC:/docker-proxy-filter.sh" &
PROXY_PID=$!

# Wait until the proxy socket is available before continuing
for _ in $(seq 1 50); do
    [ -S "${PROXY_SOCK}" ] && break
    if ! kill -0 "${PROXY_PID}" 2>/dev/null; then
        log "Failed to start proxy socket."
        exit 1
    fi
    sleep 0.1
done

if [ ! -S "${PROXY_SOCK}" ]; then
    log "Timed out while waiting for proxy socket to become available"
    exit 1
fi

log "proxy is up (pid ${PROXY_PID}); handing off to ${DEFAULT_ENTRYPOINT}"

exec "${DEFAULT_ENTRYPOINT}" "$@"