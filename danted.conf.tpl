# Dante SOCKS5 server configuration (template — rendered at container startup)

# The server listens on all interfaces
internal: ${DANTE_INTERNAL_ADDR} port=${DANTE_PORT}

# Outbound interface
external: ${DANTE_EXTERNAL_IFACE}

# Authentication methods
socksmethod: ${DANTE_SOCKSMETHOD}

# Logging
logoutput: ${DANTE_LOG_OUTPUT}

# --- Client rules (who can connect to the proxy) ---

${DANTE_TRUSTED_SUBNET_RULE}

# Allow connections from any IP if they authenticate
client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    socksmethod: username
}

# Block everything else
client block {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: error
}

# --- SOCKS rules (what traffic is allowed through) ---

# Authenticated users can access anything
socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    socksmethod: username
    log: connect error
}

${DANTE_TRUSTED_SOCKS_RULE}

# Block everything else
socks block {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect error
}
