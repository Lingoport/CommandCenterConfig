#!/bin/bash
# shellcheck disable=SC2154  # settings come from install.conf
#
# Install the Localyzer MCP Server.
#
# Reads install.conf (next to this script), writes the server settings to
# $home_directory/mcp/config/mcp.conf, and starts the container. After that,
# edit mcp.conf and run 'sudo docker restart localyzer-mcp' to apply changes.
#
# Copyright (c) Lingoport 2026

if [[ "$(id -u)" != "0" ]]; then
    echo "This script needs to be run with sudo."
    echo "Please run it as 'sudo bash InstallMCP.sh'."
    exit 1
fi

echo
echo "Installing the Localyzer MCP Server ..."
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
    echo "Exiting Localyzer MCP Server Install."
    exit 1
}

#
# ask for a setting if install.conf left it empty: ask_if_empty <variable> <description> [secret]
#
ask_if_empty() {
    local name=$1 what=$2 secret=$3 result
    if [[ -z "${!name}" ]]; then
        echo
        if [[ -n "$secret" ]]; then
            read -rsp "Please enter $what [Q/q to quit install]: " result
            echo
        else
            read -rp "Please enter $what [Q/q to quit install]: " result
        fi
        if [[ "$result" == "Q" || "$result" == "q" ]]; then
            fail "Install cancelled."
        elif [[ -z "$result" ]]; then
            fail "Failed to provide $what."
        fi
        printf -v "$name" '%s' "$result"
    fi
}

command -v docker > /dev/null || fail "Docker is not installed. Install Docker first (docker-ce)."
command -v curl > /dev/null || fail "curl is not installed. Install it first (sudo dnf install curl)."

#
# defaults and checks
#
container_name=${container_name:-localyzer-mcp}
docker_image=${docker_image:-lingoport/localyzer-mcp}
auth_modes=${auth_modes:-token}
cc_auth_style=${cc_auth_style:-legacy}
network_mode=${network_mode:-bridge}

ask_if_empty home_directory "your home directory"
ask_if_empty mcp_image_version "the Localyzer MCP version"
ask_if_empty serverPort "the MCP server port"
ask_if_empty public_host "the public host name AI clients use (e.g. mcp.yourcompany.com)"

[[ "$serverPort" =~ ^[0-9]+$ ]] || fail "serverPort must be a number, got '$serverPort'."
[[ "$network_mode" == "bridge" || "$network_mode" == "host" ]] || fail "network_mode must be bridge or host, got '$network_mode'."
case "$auth_modes" in
    token|oauth|oauth,token|token,oauth) ;;
    *) fail "auth_modes must be token, oauth or oauth,token, got '$auth_modes'." ;;
esac
case "$cc_auth_style" in
    legacy|auto|token-only) ;;
    *) fail "cc_auth_style must be legacy, auto or token-only, got '$cc_auth_style'." ;;
esac

if [[ "$auth_modes" == *token* ]]; then
    ask_if_empty cc_url "the Command Center URL, including /command-center"
    [[ "$cc_url" =~ ^https?:// ]] || fail "cc_url must start with https:// (or http://), got '$cc_url'."
fi
if [[ "$auth_modes" == *oauth* ]]; then
    ask_if_empty oidc_issuer "the OIDC issuer URL"
    if [[ "$network_mode" == "bridge" && "$oidc_jwks_url" =~ //(127\.0\.0\.1|localhost)[:/] ]]; then
        echo
        echo "Warning: oidc_jwks_url points at this host's loopback, which the container"
        echo "cannot reach with network_mode=bridge. Set network_mode=host in install.conf."
    fi
fi

if [[ -n "$docker_username" ]]; then
    ask_if_empty docker_account_token "Docker Hub account token" secret
fi

mcp_dir=$home_directory/mcp
config_dir=$mcp_dir/config
data_dir=$mcp_dir/data
config_file=$config_dir/mcp.conf
image=$docker_image:$mcp_image_version

if docker container inspect "$container_name" > /dev/null 2>&1; then
    fail "A container named $container_name already exists. Use UpdateMCP.sh to update it, or UninstallMCP.sh first."
fi

#
# get the image
#
if [[ -n "$docker_username" ]]; then
    echo "$docker_account_token" | docker login -u "$docker_username" --password-stdin || fail "Docker Hub login failed."
    docker pull "$image" || fail "Could not pull $image."
else
    docker image inspect "$image" > /dev/null 2>&1 || fail "Image $image not found on this host. Build it, or set docker_username in install.conf."
    echo "Using the local image $image."
fi

#
# folders and settings file
#
mkdir -p "$config_dir" "$data_dir" || fail "Could not create $mcp_dir."
# The container runs as uid 10001: it reads the settings and writes the token-store database.
chown 10001:10001 "$data_dir" && chmod 750 "$data_dir"

if [[ -e "$config_file" ]]; then
    echo "Keeping the existing $config_file (install.conf server settings are not applied)."
else
    if [[ "$auth_modes" == *oauth* && -z "$token_store_master_key" ]]; then
        token_store_master_key=$(docker run --rm "$image" token-store generate-key 2> /dev/null) \
            || fail "Could not generate a token-store key."
        echo "Generated a new token-store key and saved it in $config_file."
    fi
    (
        umask 027
        {
            echo "# Localyzer MCP server settings, read when the container starts."
            echo "# After editing: sudo docker restart $container_name"
            echo "# One KEY=VALUE per line. No quotes needed, JSON included. Empty means not set."
            echo "# UpdateMCP.sh never overwrites this file. Port, network and paths come"
            echo "# from install.conf and the image, not from here."
            echo
            printf 'AUTH_MODES=%s\n' "$auth_modes"
            printf 'MCP_PUBLIC_HOST=%s\n' "$public_host"
            printf 'CC_URL=%s\n' "$cc_url"
            printf 'CC_AUTH_STYLE=%s\n' "$cc_auth_style"
            echo
            echo "# OAuth path (AUTH_MODES includes oauth)"
            printf 'OIDC_ISSUER=%s\n' "$oidc_issuer"
            printf 'OIDC_JWKS_URL=%s\n' "$oidc_jwks_url"
            echo "OIDC_AUDIENCE="
            printf 'CLIENT_ORG_MAP=%s\n' "$client_org_map"
            printf 'DEFAULT_ORG_ID=%s\n' "$default_org_id"
            printf 'TOKEN_STORE_MASTER_KEY=%s\n' "$token_store_master_key"
        } > "$config_file"
    ) || fail "Could not write $config_file."
    echo "Wrote $config_file."
fi
chown root:10001 "$config_dir" "$config_file" && chmod 750 "$config_dir" && chmod 640 "$config_file"

#
# start the container
#
run_args=(-d --name "$container_name" --restart unless-stopped
          -v "$config_dir:/config:ro" -v "$data_dir:/data")
if [[ "$network_mode" == "host" ]]; then
    run_args+=(--network host -e MCP_HTTP_HOST=127.0.0.1 -e "MCP_HTTP_PORT=$serverPort")
else
    run_args+=(-p "127.0.0.1:$serverPort:8088")
fi

container_id=$(docker run "${run_args[@]}" "$image") || fail "The container failed to start."
echo "$container_id" > "$mcp_dir/mcp_container_id.txt"
echo "Localyzer MCP starting, container id is $container_id"

#
# wait until it answers
#
for _ in $(seq 1 30); do
    if health=$(curl -fsS "http://127.0.0.1:$serverPort/healthz" 2> /dev/null); then
        echo
        echo "Localyzer MCP Server is running: $health"
        echo
        echo "Next:"
        echo "  - Point Apache's /mcp-key (and /mcp) routes at http://127.0.0.1:$serverPort"
        echo "  - Change settings in $config_file, then: sudo docker restart $container_name"
        echo "  - Logs: sudo docker logs -f $container_name"
        exit 0
    fi
    sleep 1
done

echo
echo "The Localyzer MCP Server did not answer on port $serverPort within 30 seconds. Last log lines:"
docker logs --tail 30 "$container_name"
fail "Fix the problem shown above in $config_file, then run: sudo docker restart $container_name"
