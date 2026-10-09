# Lingoport MCP Server install

These scripts install the Lingoport MCP Server as a Docker container, the same
way as Command Center and Incontext:

```
MCP/
  install.conf      settings for the install (edit this first)
  InstallMCP.sh     first install
  UpdateMCP.sh      move to the version in install.conf
  UninstallMCP.sh   remove the container, keep settings and data
```

Run them from this folder with `sudo bash <script>`.

> **This repository is public.** Never commit an `install.conf` that contains a
> Docker Hub token or a `token_store_master_key`. Leave those empty here: the
> install asks for the Docker Hub token, and generates the master key itself
> (see [The token-store master key](#the-token-store-master-key)).

## How the settings flow

1. You fill in `install.conf`.
2. `InstallMCP.sh` writes the server settings once to
   `$home_directory/mcp/config/mcp.conf` and starts the container.
3. From then on, **`mcp.conf` is the file to edit**, followed by
   `sudo docker restart lingoport-mcp`. Changing server settings in
   `install.conf` after the first install has no effect, and `UpdateMCP.sh`
   never overwrites `mcp.conf`.

Only the version, port and network in `install.conf` are read again, by
`UpdateMCP.sh`.

| Host path | What |
|---|---|
| `$home_directory/mcp/config/mcp.conf` | Server settings (root:10001, mode 640; read with sudo) |
| `$home_directory/mcp/data/` | Token-store database, OAuth path only |
| `$home_directory/mcp/mcp_container_id.txt` | Running container id |

## Settings in install.conf

| Setting | Needed for | Meaning |
|---|---|---|
| `home_directory` | always | `mcp/config` and `mcp/data` are created here, e.g. `/home/centos` |
| `mcp_image_version` | always | Image tag, e.g. `1.0.1` |
| `serverPort` | always | Port on `127.0.0.1`; Apache proxies `/mcp-key` and `/mcp` to it |
| `public_host` | always | Host name AI clients use, e.g. `mcp.yourcompany.com` |
| `cc_url` | token path | Command Center URL including `/command-center` |
| `auth_modes` | always | `token`, `oauth`, or `oauth,token` |
| `cc_auth_style` | token path | `legacy` (username + token), `auto`, or `token-only` |
| `oidc_issuer` | OAuth path | Issuer URL, e.g. `https://mcp.yourcompany.com/auth/realms/localyzer-mcp` |
| `oidc_jwks_url` | OAuth path, provider on this host | Loopback keys URL; needs `network_mode=host` |
| `client_org_map` | OAuth path | JSON in single quotes, e.g. `'{"localyzer-mcp-client": "acme"}'` |
| `default_org_id` | OAuth path, demo only | Org for clients not in the map; empty in production |
| `token_store_master_key` | OAuth path | **Leave empty.** See below |
| `network_mode` | always | `bridge` (default) or `host` |
| `docker_username` | always | `lingoportcustomer`; empty = use an image built on this host |
| `docker_account_token` | with `docker_username` | **Leave empty**; the install asks for it |

The two sign-in paths are independent:

- **Token path, `/mcp-key`:** each client sends its own Command Center
  username and token in headers. The server stores nothing, so it needs
  **no master key**.
- **OAuth path, `/mcp`:** clients sign in through an OIDC provider (e.g.
  Keycloak). The server looks up the Command Center credentials for the
  caller's org in the token store, which is encrypted with the master key.

## The token-store master key

`TOKEN_STORE_MASTER_KEY` encrypts the Command Center credentials kept in
`mcp/data/token_store.db`. It is a Fernet key: 44 characters of URL-safe
base64 ending in `=`. The database alone is useless without it, and the key
alone is useless without the database, so keep them apart.

You only need it when `auth_modes` includes `oauth`.

### Option 1: let the install generate it (recommended)

Leave `token_store_master_key=` empty and set `auth_modes=oauth` or
`oauth,token`. `InstallMCP.sh` runs the image once to generate a key and
writes it straight into `mcp.conf`. It is never printed and never lands in
`install.conf`.

Do this for any **new** install with an empty token store.

### Option 2: generate it yourself

Use the image you are about to install (no container needs to be running).
Replace the version with yours:

```bash
sudo docker run --rm lingoport/lingoport-mcp:1.0.1 token-store generate-key
```

The key is the first line of the output; the lines after it are a reminder.
Put it in `mcp.conf` (after install) or, only for a one-off private install,
in `install.conf` before install. Then remove it from `install.conf` and clear
your terminal history if you pasted it anywhere.

If the server is already running, this gives the same result:

```bash
sudo docker exec lingoport-mcp token-store generate-key
```

### Option 3: reuse the key of an existing database

A new key **cannot** decrypt an existing `token_store.db`. When you bring a
database over from an earlier install (for example the native install in
`~/localyzer-mcp-demo`), bring its key with it.

Copy the database:

```bash
sudo cp /home/centos/token-store/token_store.db /home/centos/mcp/data/
```

```bash
sudo chown 10001:10001 /home/centos/mcp/data/token_store.db
```

Copy the key from the old `.env` into `mcp.conf` without printing it:

```bash
sudo sed -i "s|^TOKEN_STORE_MASTER_KEY=.*|$(grep '^TOKEN_STORE_MASTER_KEY=' /home/centos/localyzer-mcp-demo/.env)|" /home/centos/mcp/config/mcp.conf
```

```bash
sudo docker restart lingoport-mcp
```

Run this even after an OAuth install that generated its own key: the
generated key replaces nothing in the old database, it simply cannot read it.

### Adding the OAuth path later

An install with `auth_modes=token` writes an empty `TOKEN_STORE_MASTER_KEY=`.
To turn on OAuth afterwards, set `AUTH_MODES=oauth,token` and the `OIDC_*`,
`CLIENT_ORG_MAP` settings in `mcp.conf`, then add a key without printing it:

```bash
key=$(sudo docker exec lingoport-mcp token-store generate-key 2>/dev/null)
```

```bash
sudo sed -i "s|^TOKEN_STORE_MASTER_KEY=.*|TOKEN_STORE_MASTER_KEY=$key|" /home/centos/mcp/config/mcp.conf
```

```bash
unset key
```

```bash
sudo docker restart lingoport-mcp
```

Then provision each org (next section). If the host also needs
`network_mode=host` for the OIDC provider, change it in `install.conf` and run
`sudo bash UpdateMCP.sh`.

### Checking the key is set

This shows whether the line has a value, without showing the value:

```bash
sudo grep -c '^TOKEN_STORE_MASTER_KEY=.\+' /home/centos/mcp/config/mcp.conf
```

`1` means set, `0` means empty.

`token-store list` and `show` only read metadata and do not decrypt, so they
work even with the wrong key. The real test is an OAuth tool call (for
example `list_projects` from a claude.ai OAuth connector). Errors in
`sudo docker logs lingoport-mcp` tell you which problem you have:

| Message | Cause |
|---|---|
| `TOKEN_STORE_MASTER_KEY is not set` | Empty in `mcp.conf` |
| `... is not a valid Fernet key` | Truncated, quoted, or extra characters |
| `Could not decrypt a stored credential ...` | Key does not match the database (see Option 3) |

### Provisioning orgs

With the key in place, store each customer's Command Center API user. The CLI
inside the container uses the key and database from `mcp.conf` and `/data`:

```bash
sudo docker exec lingoport-mcp token-store provision --org-id acme --cc-url https://yourserver/command-center --cc-username <cc-api-user> --cc-token '<cc-api-token>'
```

```bash
sudo docker exec lingoport-mcp token-store list
```

The `org-id` must match the value in `CLIENT_ORG_MAP` (or the token's
`org_id` claim). Provisioning checks the credentials against Command Center
before storing them. Note that the token appears in your shell history; clear
it afterwards.

### Keeping and changing the key

- **Back it up** in your password manager or secret store, separately from
  backups of `mcp/data/`. If the key is lost, the stored credentials cannot be
  recovered: generate a new key, delete `token_store.db`, and provision every
  org again with its Command Center token.
- **Changing the key** has the same effect: there is no re-encrypt command
  yet, so every org must be provisioned again after the change.
- **Never** put the key in `install.conf` in this repository, in a ticket, or
  in a chat.

## Install

```bash
sudo bash InstallMCP.sh
```

Expect `Lingoport MCP Server is running: {"status": "ok", "version": ...}`.
Then point Apache's `/mcp-key` (and `/mcp`) routes at
`http://127.0.0.1:<serverPort>`, test the config, and reload:

```bash
sudo apachectl configtest
```

```bash
sudo systemctl reload httpd
```

## Day to day

```bash
sudo docker logs -f lingoport-mcp
```

```bash
sudo docker restart lingoport-mcp
```

To update, set the new `mcp_image_version` in `install.conf`, then:

```bash
sudo bash UpdateMCP.sh
```

The old container is kept, stopped, as `lingoport-mcp-previous`, and is
started again automatically if the new one does not answer within 30 seconds.
Remove it once you are happy:

```bash
sudo docker rm lingoport-mcp-previous
```

`UninstallMCP.sh` removes the container but keeps `mcp.conf`, the database and
therefore the key.
