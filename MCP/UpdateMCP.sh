#!/bin/bash
# shellcheck disable=SC2154  # settings come from install.conf
#
# Update the Localyzer MCP Server to the version in install.conf.
#
# Keeps $home_directory/mcp/config/mcp.conf and the token-store data as they
# are. The old container is kept, stopped, as <container_name>-previous; if the
# new one does not answer, the old one is started again.
#
# Copyright (c) Lingoport 2026

if [[ "$(id -u)" != "0" ]]; then
    echo "This script needs to be run with sudo."
    echo "Please run it as 'sudo bash UpdateMCP.sh'."
    exit 1
fi

echo
echo "Updating the Localyzer MCP Server ..."
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

fail() {
    echo
    echo "$1"
    echo "Exiting Localyzer MCP Server Update."
    exit 1
}

command -v docker > /dev/null || fail "Docker is not installed."
command -v curl > /dev/null || fail "curl is not installed. Install it first (sudo dnf install curl)."

container_name=${container_name:-localyzer-mcp}
docker_image=${docker_image:-lingoport/localyzer-mcp}
network_mode=${network_mode:-bridge}
previous=$container_name-previous

[[ -n "$home_directory" ]] || fail "home_directory is not set in install.conf."
[[ -n "$mcp_image_version" ]] || fail "mcp_image_version is not set in install.conf."
[[ "$serverPort" =~ ^[0-9]+$ ]] || fail "serverPort must be a number, got '$serverPort'."
[[ "$network_mode" == "bridge" || "$network_mode" == "host" ]] || fail "network_mode must be bridge or host, got '$network_mode'."

mcp_dir=$home_directory/mcp
config_dir=$mcp_dir/config
data_dir=$mcp_dir/data
image=$docker_image:$mcp_image_version

docker container inspect "$container_name" > /dev/null 2>&1 || fail "No container named $container_name. Run InstallMCP.sh first."
[[ -e "$config_dir/mcp.conf" ]] || fail "$config_dir/mcp.conf is missing. Run InstallMCP.sh first."

#
# get the new image before touching the running server
#
if [[ -n "$docker_username" ]]; then
    if [[ -z "$docker_account_token" ]]; then
        echo
        read -rsp "Please enter Docker Hub account token [Q/q to quit update]: " docker_account_token
        echo
        [[ -n "$docker_account_token" && "$docker_account_token" != "Q" && "$docker_account_token" != "q" ]] || fail "Update cancelled."
    fi
    echo "$docker_account_token" | docker login -u "$docker_username" --password-stdin || fail "Docker Hub login failed."
    docker pull "$image" || fail "Could not pull $image. The running server was not changed."
else
    docker image inspect "$image" > /dev/null 2>&1 || fail "Image $image not found on this host. The running server was not changed."
fi

#
# keep the current container, stopped, for rollback
#
if docker container inspect "$previous" > /dev/null 2>&1; then
    docker rm -f "$previous" > /dev/null || fail "Could not remove the old $previous container."
fi
old_image=$(docker inspect --format '{{.Config.Image}}' "$container_name")
docker stop "$container_name" > /dev/null || fail "Could not stop $container_name."
docker rename "$container_name" "$previous" || fail "Could not rename $container_name."
docker update --restart=no "$previous" > /dev/null

#
# start the new container with the same settings and data
#
run_args=(-d --name "$container_name" --restart unless-stopped
          -v "$config_dir:/config:ro" -v "$data_dir:/data")
if [[ "$network_mode" == "host" ]]; then
    run_args+=(--network host -e MCP_HTTP_HOST=127.0.0.1 -e "MCP_HTTP_PORT=$serverPort")
else
    run_args+=(-p "127.0.0.1:$serverPort:8088")
fi

rollback() {
    echo
    echo "Rolling back to $old_image ..."
    docker rm -f "$container_name" > /dev/null 2>&1
    docker rename "$previous" "$container_name" \
        && docker update --restart unless-stopped "$container_name" > /dev/null \
        && docker start "$container_name" > /dev/null \
        && echo "The previous version is running again."
    fail "$1"
}

container_id=$(docker run "${run_args[@]}" "$image") || rollback "The new container failed to start."
echo "$container_id" > "$mcp_dir/mcp_container_id.txt"
echo "Localyzer MCP starting, container id is $container_id"

for _ in $(seq 1 30); do
    if health=$(curl -fsS "http://127.0.0.1:$serverPort/healthz" 2> /dev/null); then
        echo
        echo "Localyzer MCP Server updated from $old_image to $image: $health"
        echo "The previous container is kept, stopped, as $previous."
        echo "Remove it once you are happy: sudo docker rm $previous"
        exit 0
    fi
    sleep 1
done

echo
echo "The new version did not answer on port $serverPort within 30 seconds. Last log lines:"
docker logs --tail 30 "$container_name"
docker inspect --format '{{.Id}}' "$previous" > "$mcp_dir/mcp_container_id.txt" 2> /dev/null
rollback "Update to $image failed."
