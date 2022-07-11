#!/usr/bin/dumb-init /bin/bash

# run phantom
echo "[info] Starting Phantom..."
/opt/phantom/phantom-linux -bind 0.0.0.0 -bind_port 19133 -server "${REMOTE_MINECRAFT_IP}":"${REMOTE_MINECRAFT_PORT}" -timeout "${CLEANUP_TIMEOUT}"
echo "[info] Phantom started"
