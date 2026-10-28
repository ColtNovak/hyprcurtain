#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

PREFIX="${PREFIX:-/usr/local}"
BIN="$PREFIX/bin"
LUA="$PREFIX/share/lua/5.5"
UNITS="$PREFIX/lib/systemd/user"
DROPIN="$UNITS/app-dev.lizardbyte.app.Sunshine.service.d/hyprcurtain.conf"
RULE=/etc/udev/rules.d/90-hyprcurtain.rules
SUNSHINE="${XDG_CONFIG_HOME:-$HOME/.config}/sunshine/sunshine.conf"

if [[ -e ${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hyprcurtain ]]; then
    echo "a stream is running, try again after it ends" >&2
    exit 1
fi

if [[ ${1:-} == uninstall ]]; then
    systemctl --user stop hyprcurtain.service 2>/dev/null || true
    sudo rm -f "$BIN/hyprcurtain" "$LUA/hyprcurtain.lua" "$UNITS/hyprcurtain.service" "$DROPIN" "$RULE"
    sudo rmdir --ignore-fail-on-non-empty "$(dirname "$DROPIN")"
    sudo udevadm control --reload
    systemctl --user daemon-reload
    echo "removed. take global_prep_cmd out of $SUNSHINE"
    exit 0
fi

for dep in hyprctl jq curl flock; do
    command -v "$dep" >/dev/null || { echo "missing $dep" >&2; exit 1; }
done

sudo install -Dm755 hyprcurtain "$BIN/hyprcurtain"
sudo install -Dm644 hyprcurtain.lua "$LUA/hyprcurtain.lua"
sed "s|@BIN@|$BIN|" hyprcurtain.service | sudo install -Dm644 /dev/stdin "$UNITS/hyprcurtain.service"
sed "s|@BIN@|$BIN|" sunshine-hyprcurtain.conf | sudo install -Dm644 /dev/stdin "$DROPIN"

sudo install -Dm644 90-hyprcurtain.rules "$RULE"
sudo udevadm control --reload
sudo chgrp input /sys/class/input/input*/inhibited
sudo chmod g+w /sys/class/input/input*/inhibited

systemctl --user daemon-reload
systemctl --user try-restart hyprcurtain.service

if [[ -f $SUNSHINE ]] && ! grep -q '^global_prep_cmd' "$SUNSHINE"; then
    echo "global_prep_cmd = [{\"do\":\"$BIN/hyprcurtain start\",\"undo\":\"$BIN/hyprcurtain stop\"}]" >> "$SUNSHINE"
    grep -q '^capture' "$SUNSHINE" || echo "capture = wlr" >> "$SUNSHINE"
    echo "added global_prep_cmd to $SUNSHINE, restart sunshine to pick it up"
elif ! grep -qs "$BIN/hyprcurtain" "$SUNSHINE"; then
    echo "set this in $SUNSHINE (or the web ui):"
    echo "  capture = wlr"
    echo "  global_prep_cmd = [{\"do\":\"$BIN/hyprcurtain start\",\"undo\":\"$BIN/hyprcurtain stop\"}]"
fi

id -nG | grep -qw input || echo "add yourself to the input group and log back in: sudo usermod -aG input $USER"
echo "done. add require(\"hyprcurtain\") at the end of your hyprland.lua if it isn't there yet"
