#!/bin/bash

phantom_cli="/opt/phantom/phantom-linux"

if [[ -n "${MINECRAFT_SERVER}" ]]; then

	phantom_cli="${phantom_cli} -server ${MINECRAFT_SERVER}"

else

	echo "[crit] No Minecraft Bedrock server specified via env var 'MINECRAFT_SERVER', exiting..."
	exit 1

fi

if [[ -n "${LISTEN_IP}" ]]; then

	phantom_cli="${phantom_cli} -bind ${LISTEN_IP}"

fi

if [[ -n "${LISTEN_PORT}" ]]; then

	phantom_cli="${phantom_cli} -bind_port ${LISTEN_PORT}"

fi

if [[ -n "${CLEANUP_TIMEOUT}" ]]; then

	phantom_cli="${phantom_cli} -timeout ${CLEANUP_TIMEOUT}"

fi

# run phantom
echo "[info] Starting Phantom with command '${phantom_cli}'..."
eval "${phantom_cli}"
echo "[info] Phantom started"