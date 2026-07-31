#!/bin/bash
export SOCKS_PORT="${PORT:-1080}"
export SNI="${SNI:-ganderrice.gander-rice-kindle.workers.dev}"
export FINGERPRINT="${FINGERPRINT:-chrome}"
export CFG="${VLESS_CONFIGS:-[]}"

python3 -c "
import json, os

cfgs = json.loads(os.environ.get('CFG','[]'))
sni = os.environ['SNI']
fp = os.environ['FINGERPRINT']
port = os.environ['SOCKS_PORT']

outbounds = []
tags = []
for i, c in enumerate(cfgs):
    tag = f'vless-{i}'
    tags.append(tag)
    outbounds.append({
        'protocol': 'vless', 'tag': tag,
        'settings': {'vnext': [{
            'address': c['addr'], 'port': int(c.get('port',443)),
            'users': [{'id': c['id'], 'encryption': 'none'}]
        }]},
        'streamSettings': {
            'network': 'ws', 'security': 'tls',
            'wsSettings': {'path': c['path']},
            'tlsSettings': {'serverName': sni, 'fingerprint': fp}
        }
    })

config = {
    'log': {'loglevel': 'warning'},
    'inbounds': [{'port': port, 'protocol': 'http', 'tag': 'http-in', 'settings': {}}],
    'outbounds': outbounds,
    'routing': {
        'rules': [{'type': 'field', 'inboundTag': ['http-in'], 'balancerTag': 'vless-pool'}],
        'balancers': [{'tag': 'vless-pool', 'selector': tags}]
    }
}
with open('/etc/xray/config.json','w') as f:
    json.dump(config, f, indent=2)
print(f'Generated {len(tags)} VLESS outbounds → SOCKS5:{port}')
" 2>&1
exec /usr/bin/xray run -c /etc/xray/config.json
