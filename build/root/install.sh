#!/bin/bash

# exit script if return code != 0
set -e

# release tag name from build arg, stripped of build ver using string manipulation
release_tag_name="${1//-[0-9][0-9]/}"

# build scripts
####

# download build scripts from github
curl --connect-timeout 5 --max-time 600 --retry 5 --retry-delay 0 --retry-max-time 60 -o /tmp/scripts-master.zip -L https://github.com/binhex/scripts/archive/master.zip

# unzip build scripts
unzip /tmp/scripts-master.zip -d /tmp

# move shell scripts to /root
mv /tmp/scripts-master/shell/arch/docker/*.sh /usr/local/bin/

# detect image arch
####

OS_ARCH=$(cat /etc/os-release | grep -P -o -m 1 "(?=^ID\=).*" | grep -P -o -m 1 "[a-z]+$")
if [[ ! -z "${OS_ARCH}" ]]; then
	if [[ "${OS_ARCH}" == "arch" ]]; then
		OS_ARCH="x86-64"
	else
		OS_ARCH="aarch64"
	fi
	echo "[info] OS_ARCH defined as '${OS_ARCH}'"
else
	echo "[warn] Unable to identify OS_ARCH, defaulting to 'x86-64'"
	OS_ARCH="x86-64"
fi

# pacman packages
####

# define pacman packages
pacman_packages=""

# install compiled packages using pacman
if [[ ! -z "${pacman_packages}" ]]; then
	pacman -S --needed $pacman_packages --noconfirm
fi

# aur packages
####

# define aur packages
aur_packages=""

# call aur install script (arch user repo)
source aur.sh

# github releases
####

github.sh --install-path "/opt/phantom" --download-assets phantom-linux --github-owner jhead --github-repo phantom --query-type pre-release
chmod +x /opt/phantom/phantom-linux

# container perms
####

# define comma separated list of paths
install_paths="/opt/phantom,/home/nobody"

# split comma separated string into list for install paths
IFS=',' read -ra install_paths_list <<< "${install_paths}"

# process install paths in the list
for i in "${install_paths_list[@]}"; do

	# confirm path(s) exist, if not then exit
	if [[ ! -d "${i}" ]]; then
		echo "[crit] Path '${i}' does not exist, exiting build process..." ; exit 1
	fi

done

# convert comma separated string of install paths to space separated, required for chmod/chown processing
install_paths=$(echo "${install_paths}" | tr ',' ' ')

# set permissions for container during build - Do NOT double quote variable for install_paths otherwise this will wrap space separated paths as a single string
chmod -R 775 ${install_paths}

# create file with contents of here doc, note EOF is NOT quoted to allow us to expand current variable 'install_paths'
# we use escaping to prevent variable expansion for PUID and PGID, as we want these expanded at runtime of init.sh
cat <<EOF > /tmp/permissions_heredoc

# get previous puid/pgid (if first run then will be empty string)
previous_puid=\$(cat "/root/puid" 2>/dev/null || true)
previous_pgid=\$(cat "/root/pgid" 2>/dev/null || true)

# if first run (no puid or pgid files in /tmp) or the PUID or PGID env vars are different
# from the previous run then re-apply chown with current PUID and PGID values.
if [[ ! -f "/root/puid" || ! -f "/root/pgid" || "\${previous_puid}" != "\${PUID}" || "\${previous_pgid}" != "\${PGID}" ]]; then

	# set permissions inside container - Do NOT double quote variable for install_paths otherwise this will wrap space separated paths as a single string
	chown -R "\${PUID}":"\${PGID}" ${install_paths}

fi

# write out current PUID and PGID to files in /root (used to compare on next run)
echo "\${PUID}" > /root/puid
echo "\${PGID}" > /root/pgid

EOF

# replace permissions placeholder string with contents of file (here doc)
sed -i '/# PERMISSIONS_PLACEHOLDER/{
    s/# PERMISSIONS_PLACEHOLDER//g
    r /tmp/permissions_heredoc
}' /usr/local/bin/init.sh
rm /tmp/permissions_heredoc

# env vars
####

cat <<'EOF' > /tmp/envvars_heredoc

export REMOTE_MINECRAFT_IP=$(echo "${REMOTE_MINECRAFT_IP}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')
if [[ ! -z "${REMOTE_MINECRAFT_IP}" ]]; then
	echo "[info] REMOTE_MINECRAFT_IP defined as '${REMOTE_MINECRAFT_IP}'" | ts '%Y-%m-%d %H:%M:%.S'
else
	echo "[crit] REMOTE_MINECRAFT_IP not defined,(via -e REMOTE_MINECRAFT_IP), exiting..." | ts '%Y-%m-%d %H:%M:%.S'
	exit 1
fi

export REMOTE_MINECRAFT_PORT=$(echo "${REMOTE_MINECRAFT_PORT}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')
if [[ ! -z "${REMOTE_MINECRAFT_PORT}" ]]; then
	echo "[info] REMOTE_MINECRAFT_PORT defined as '${REMOTE_MINECRAFT_PORT}'" | ts '%Y-%m-%d %H:%M:%.S'
else
	echo "[info] REMOTE_MINECRAFT_PORT not defined,(via -e REMOTE_MINECRAFT_PORT), defaulting to '19132'" | ts '%Y-%m-%d %H:%M:%.S'
	export REMOTE_MINECRAFT_PORT="19132"
fi

export CLEANUP_TIMEOUT=$(echo "${CLEANUP_TIMEOUT}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')
if [[ ! -z "${CLEANUP_TIMEOUT}" ]]; then
	echo "[info] CLEANUP_TIMEOUT defined as '${CLEANUP_TIMEOUT}'" | ts '%Y-%m-%d %H:%M:%.S'
else
	echo "[info] CLEANUP_TIMEOUT not defined,(via -e CLEANUP_TIMEOUT), defaulting to '60' seconds" | ts '%Y-%m-%d %H:%M:%.S'
	export CLEANUP_TIMEOUT="60"
fi

EOF

# replace env vars placeholder string with contents of file (here doc)
sed -i '/# ENVVARS_PLACEHOLDER/{
    s/# ENVVARS_PLACEHOLDER//g
    r /tmp/envvars_heredoc
}' /usr/local/bin/init.sh
rm /tmp/envvars_heredoc

# cleanup
cleanup.sh
