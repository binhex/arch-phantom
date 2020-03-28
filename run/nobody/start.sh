#!/bin/bash

# note phantom always listens on port 19132, as well as specific bind_port defined below
phantom_cli="/opt/phantom/phantom-linux -bind 0.0.0.0 -bind_port 19133"

if [[ -n "${MINECRAFT_SERVER}" ]]; then

	phantom_cli="${phantom_cli} -server ${MINECRAFT_SERVER}"

else

	echo "[crit] No Minecraft Bedrock server specified via env var 'MINECRAFT_SERVER', exiting..."
	exit 1

fi

if [[ -n "${CLEANUP_TIMEOUT}" ]]; then

	phantom_cli="${phantom_cli} -timeout ${CLEANUP_TIMEOUT}"

fi

# run phantom
echo "[info] Starting Phantom with command '${phantom_cli}'..."
eval "${phantom_cli}"
echo "[info] Phantom started"
