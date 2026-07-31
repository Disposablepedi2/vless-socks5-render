#!/bin/bash
export SNI="${SNI:-ganderrice.gander-rice-kindle.workers.dev}"
export FINGERPRINT="${FINGERPRINT:-chrome}"
export SOCKS_PORT="${PORT:-1080}"

# Read VLESS configs from env (VLESS_CONFIGS is a JSON array of {addr,port,id,path} objects)
CONFIGS="${VLESS_CONFIGS:-[]}"

# Generate outbound blocks
python3 << PYEOF
import json, os

configs = json.loads(os.environ.get('VLESS_CONFIGS', '[]'))
sni = os.environ.get('SNI', 'ganderrice.gander-rice-kindle.workers.dev')
fp = os.environ.get('FINGERPRINT', 'chrome')

outbounds = []
tags = []

for i, cfg in enumerate(configs):
    tag = f"vless-{i}"
    tags.append(tag)
    ob = {
        "protocol": "vless",
        "tag": tag,
        "settings": {"vnext": [{
            "address": cfg["addr"],
            "port": int(cfg.get("port", 443)),
            "users": [{"id": cfg["id"], "encryption": "none"}]
        }]},
        "streamSettings": {
            "network": "ws",
            "security": "tls",
            "wsSettings": {"path": cfg["path"]},
            "tlsSettings": {
                "serverName": sni,
                "fingerprint": fp
            }
        }
    }
    outbounds.append(ob)

# Add direct outbound as fallback
outbounds.append({"protocol": "freedom", "tag": "direct"})

print(json.dumps(outbounds, indent=2))
print("---TAGS---")
print(",".join(tags))
PYEOF
echo "Generated config"
exec /usr/bin/xray run -c /etc/xray/config.json
