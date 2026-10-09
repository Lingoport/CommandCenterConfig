#!/bin/bash
# shellcheck disable=SC2154  # settings come from install.conf
#
# Uninstall the Localyzer MCP Server.
#
# Removes the container (and the stopped -previous one kept by UpdateMCP.sh).
# Keeps $home_directory/mcp: mcp.conf (settings) and data/ (token store).
#
# Copyright (c) Lingoport 2026

if [[ "$(id -u)" != "0" ]]; then
    echo "This script needs to be run with sudo."
    echo "Please run it as 'sudo bash UninstallMCP.sh'."
    exit 1
fi

echo
echo "Uninstalling the Localyzer MCP Server ..."
echo

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

#
# read in config file (tolerates Windows line endings)
#
if [[ -e "$script_dir/install.conf" ]]; then
    # shellcheck source=/dev/null
    source <(tr -d '\r' < "$script_dir/install.conf")
    echo "Reading configured information from install.conf file."
fi

command -v docker > /dev/null || { echo "Docker is not installed."; exit 1; }

container_name=${container_name:-localyzer-mcp}
mcp_dir=${home_directory:-}/mcp

removed=0
for name in "$container_name" "$container_name-previous"; do
    if docker container inspect "$name" > /dev/null 2>&1; then
        docker rm -f "$name" > /dev/null || { echo "Failed to stop/remove Docker container $name"; exit 1; }
        echo "Removed container $name."
        removed=1
    fi
done
rm -f "$mcp_dir/mcp_container_id.txt"

if [[ "$removed" == "0" ]]; then
    echo "No $container_name container found; nothing to remove."
else
    echo "Localyzer MCP Server has been successfully uninstalled."
fi
if [[ -n "$home_directory" && -d "$mcp_dir" ]]; then
    echo
    echo "Kept $mcp_dir (mcp.conf and the token-store data)."
    echo "To delete them too: sudo rm -rf $mcp_dir"
fi
