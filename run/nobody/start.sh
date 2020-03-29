#!/bin/bash

# note phantom always listens on port 19132, as well as specific bind_port defined below
phantom_cli="/opt/phantom/phantom-linux -bind 0.0.0.0 -bind_port 19133"

if [[ -n "${REMOTE_MINECRAFT_IP}" ]]; then

	if [[ -n "${REMOTE_MINECRAFT_PORT}" ]]; then

		phantom_cli="${phantom_cli} -server ${REMOTE_MINECRAFT_IP}:${REMOTE_MINECRAFT_PORT}"

	else

		echo "[warn] No Minecraft Bedrock server port specified via env var 'REMOTE_MINECRAFT_PORT', assuming port '19132'"
		phantom_cli="${phantom_cli} -server ${REMOTE_MINECRAFT_IP}:19132"

	fi

else

	echo "[crit] No Minecraft Bedrock server IP specified via env var 'REMOTE_MINECRAFT_IP', exiting..."
	exit 1

fi

if [[ -n "${CLEANUP_TIMEOUT}" ]]; then

	phantom_cli="${phantom_cli} -timeout ${CLEANUP_TIMEOUT}"

fi

# run phantom
echo "[info] Starting Phantom with command '${phantom_cli}'..."
eval "${phantom_cli}"
echo "[info] Phantom started"
