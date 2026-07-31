#!/bin/bash
# Generate config from environment variables
export SNI="${SNI:-ganderrice.gander-rice-kindle.workers.dev}"
export FINGERPRINT="${FINGERPRINT:-chrome}"
export PATH_WS="${PATH_WS:-/}"
export REMOTE_PORT="${REMOTE_PORT:-443}"
export SOCKS_PORT="${PORT:-1080}"

envsubst < /etc/xray/config.json.template > /etc/xray/config.json
echo "Starting Xray with:"
echo "  Inbound: SOCKS5 on port $SOCKS_PORT"
echo "  Outbound: VLESS → $REMOTE_ADDR:$REMOTE_PORT → $PATH_WS"
exec /usr/bin/xray run -c /etc/xray/config.json
