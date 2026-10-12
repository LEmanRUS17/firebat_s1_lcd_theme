#!/bin/sh
# Install the "Home server dashboard" theme (landscape + portrait layouts in one theme)
# into an existing s1panel installation (https://github.com/tjaworski/AceMagic-S1-LED-TFT-Linux).
#
# Usage (as root, from this folder):  sh install.sh [/opt/acemagic/s1panel]

set -e

SRC=$(cd "$(dirname "$0")" && pwd)
S1=${1:-/opt/acemagic/s1panel}
TS=$(date +%Y%m%d%H%M%S)

[ -f "$S1/main.js" ] || { echo "s1panel not found in $S1"; exit 1; }

echo "== backup to *.bak-$TS"
cp "$S1/api.js" "$S1/api.js.bak-$TS"
cp "$S1/widgets/iconify.js" "$S1/widgets/iconify.js.bak-$TS"
cp "$S1/config.json" "$S1/config.json.bak-$TS"
[ -f "$S1/themes/homeserver/landscape_dashboard.json" ] && \
    cp "$S1/themes/homeserver/landscape_dashboard.json" "$S1/themes/homeserver/landscape_dashboard.json.bak-$TS"

echo "== code changes (dual layout + local icons)"
if grep -q "per-orientation layouts" "$S1/api.js" && grep -q "ICON_DIR" "$S1/widgets/iconify.js"; then
    echo "   already applied"
elif command -v patch >/dev/null && patch -d "$S1" -p1 --dry-run < "$SRC/patches/s1panel-dual-layout-local-icons.patch" >/dev/null; then
    patch -d "$S1" -p1 < "$SRC/patches/s1panel-dual-layout-local-icons.patch"
else
    echo "   patch does not apply cleanly, copying patched files instead"
    cp "$SRC/patched/api.js" "$S1/api.js"
    cp "$SRC/patched/widgets/iconify.js" "$S1/widgets/iconify.js"
fi

echo "== theme and icons"
mkdir -p "$S1/themes/homeserver" "$S1/icons/mdi"
cp "$SRC/themes/homeserver/landscape_dashboard.json" "$S1/themes/homeserver/"
cp "$SRC"/icons/mdi/*.svg "$S1/icons/mdi/"

echo "== config.json (activate theme, ensure sensors)"
python3 - "$S1/config.json" <<'EOF'
import json, sys
p = sys.argv[1]
c = json.load(open(p))
theme = "themes/homeserver/landscape_dashboard.json"
c["theme"] = theme
if not any(t.get("config") == theme for t in c.setdefault("theme_list", [])):
    c["theme_list"].append({"name": "Home server dashboard", "config": theme})
need = [
    ("sensors/network.js", {"interface": "vmbr0", "max_points": 300}),
    ("sensors/space.js", {"name": "root", "mount_point": "/", "max_points": 300}),
]
for module, cfg in need:
    key = "interface" if "interface" in cfg else "name"
    if not any(s.get("module") == module and (s.get("config") or {}).get(key) == cfg[key] for s in c["sensors"]):
        c["sensors"].append({"module": module, "config": cfg})
        print("   added sensor", module, cfg)
json.dump(c, open(p, "w"), ensure_ascii=False, indent=3)
EOF

node -e "require('$S1/api.js'); require('$S1/widgets/iconify.js')" >/dev/null

echo "== restart"
systemctl restart s1panel
echo "done. Web UI: http://<host>:8686"
