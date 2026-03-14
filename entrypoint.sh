#!/bin/sh
set -e

# ── Defaults ────────────────────────────────────────────────────────────────
DANTE_INTERNAL_ADDR="${DANTE_INTERNAL_ADDR:-0.0.0.0}"
DANTE_PORT="${DANTE_PORT:-1080}"
DANTE_EXTERNAL_IFACE="${DANTE_EXTERNAL_IFACE:-eth0}"
DANTE_SOCKSMETHOD="${DANTE_SOCKSMETHOD:-username none}"
DANTE_LOG_OUTPUT="${DANTE_LOG_OUTPUT:-stderr}"

# ── Optional trusted-subnet rules (set DANTE_TRUSTED_SUBNET=192.168.1.0/24) ─
if [ -n "$DANTE_TRUSTED_SUBNET" ]; then
    DANTE_TRUSTED_SUBNET_RULE="# Allow trusted subnet without authentication
client pass {
    from: ${DANTE_TRUSTED_SUBNET} to: 0.0.0.0/0
    socksmethod: none
}"
    DANTE_TRUSTED_SOCKS_RULE="# Trusted subnet can access anything without auth
socks pass {
    from: ${DANTE_TRUSTED_SUBNET} to: 0.0.0.0/0
    socksmethod: none
    log: connect error
}"
else
    DANTE_TRUSTED_SUBNET_RULE=""
    DANTE_TRUSTED_SOCKS_RULE=""
fi

export DANTE_INTERNAL_ADDR DANTE_PORT DANTE_EXTERNAL_IFACE \
       DANTE_SOCKSMETHOD DANTE_LOG_OUTPUT \
       DANTE_TRUSTED_SUBNET_RULE DANTE_TRUSTED_SOCKS_RULE

# ── Render config from template ──────────────────────────────────────────────
envsubst < /etc/danted.conf.tpl > /etc/danted.conf

# ── Proxy users (format: "user1:pass1,user2:pass2") ──────────────────────────
if [ -n "$PROXY_USERS" ]; then
    IFS=','
    for entry in $PROXY_USERS; do
        username="${entry%%:*}"
        password="${entry#*:}"
        if ! id "$username" >/dev/null 2>&1; then
            useradd -r -s /usr/sbin/nologin "$username"
        fi
        echo "$username:$password" | chpasswd
        echo "Created proxy user: $username"
    done
    unset IFS
fi

exec danted -f /etc/danted.conf
